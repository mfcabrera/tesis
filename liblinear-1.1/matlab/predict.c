#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "linear.h"

#include "mex.h"
#include "linear_model_matlab.h"

#if MX_API_VER < 0x07030000
typedef int mwIndex;
#endif

#define CMD_LEN 2048

#define Malloc(type,n) (type *)malloc((n)*sizeof(type))

void read_sparse_instance(const mxArray *prhs, int index, struct feature_node *x, int feature_number, double bias)
{
	int i, j, low, high;
	mwIndex *ir, *jc;
	double *samples;

	ir = mxGetIr(prhs);
	jc = mxGetJc(prhs);
	samples = mxGetPr(prhs);

	// each column is one instance
	j = 0;
	low = jc[index], high = jc[index+1];
	for(i=low; i<high && (int)(ir[i])<feature_number; i++)
	{
		x[j].index = ir[i]+1;
		x[j].value = samples[i];
		j++;
 	}
	x[j].index = feature_number+1;
	x[j].value = bias;
	j++;
	x[j].index = -1;
}

static void fake_answer(mxArray *plhs[])
{
	plhs[0] = mxCreateDoubleMatrix(0, 0, mxREAL);
	plhs[1] = mxCreateDoubleMatrix(0, 0, mxREAL);
	plhs[2] = mxCreateDoubleMatrix(0, 0, mxREAL);
}

void do_predict(mxArray *plhs[], const mxArray *prhs[], struct model *model_, const int predict_probability_flag)
{
	int label_vector_row_num, label_vector_col_num;
	int feature_number, testing_instance_number;
	int instance_index;
	double *ptr_instance, *ptr_label, *ptr_predict_label;
	double *ptr_prob_estimates, *ptr_dec_values, *ptr;
	struct feature_node *x;
	mxArray *pplhs[1]; // transposed instance sparse matrix

	int correct = 0;
	int total = 0;

	int nr_class=get_nr_class(model_);
	int nr_classifier;
	double *prob_estimates=NULL;

	if(nr_class==2)
		nr_classifier=1;
	else
		nr_classifier=nr_class;

	// prhs[1] = testing instance matrix
	feature_number = mxGetN(prhs[1]);
	testing_instance_number = mxGetM(prhs[1]);
	label_vector_row_num = mxGetM(prhs[0]);
	label_vector_col_num = mxGetN(prhs[0]);

	if(label_vector_row_num!=testing_instance_number)
	{
		mexPrintf("# of labels (# of column in 1st argument) does not match # of instances (# of rows in 2nd argument).\n");
		fake_answer(plhs);
		return;
	}
	if(label_vector_col_num!=1)
	{
		mexPrintf("label (1st argument) should be a vector (# of column is 1).\n");
		fake_answer(plhs);
		return;
	}

	ptr_instance = mxGetPr(prhs[1]);
	ptr_label    = mxGetPr(prhs[0]);

	// transpose instance matrix
	if(mxIsSparse(prhs[1]))
	{
		mxArray *pprhs[1];
		pprhs[0] = mxDuplicateArray(prhs[1]);
		if(mexCallMATLAB(1, pplhs, 1, pprhs, "transpose"))
		{
			mexPrintf("Error: cannot transpose testing instance matrix\n");
			fake_answer(plhs);
			return;
		}
	}

	prob_estimates = Malloc(double, nr_class);

	plhs[0] = mxCreateDoubleMatrix(testing_instance_number, 1, mxREAL);
	if(predict_probability_flag)
		plhs[2] = mxCreateDoubleMatrix(testing_instance_number, nr_class, mxREAL);
	else
		plhs[2] = mxCreateDoubleMatrix(testing_instance_number, nr_classifier, mxREAL);

	ptr_predict_label = mxGetPr(plhs[0]);
	ptr_prob_estimates = mxGetPr(plhs[2]);
	ptr_dec_values = mxGetPr(plhs[2]);
	x = Malloc(struct feature_node, feature_number+2);
	for(instance_index=0;instance_index<testing_instance_number;instance_index++)
	{
		int i;
		double target,v;

		target = ptr_label[instance_index];

		if(mxIsSparse(prhs[1])) // prhs[1]^T is still sparse
		{
			read_sparse_instance(pplhs[0], instance_index, x, feature_number, model_->bias);
		}
		else
		{
			for(i=0;i<feature_number;i++)
			{
				x[i].index = i;
				x[i].value = ptr_instance[testing_instance_number*i+instance_index];
			}
			x[feature_number].index = feature_number;
			x[feature_number].value = 1;
			x[feature_number+1].index = -1;
		}

		if(predict_probability_flag)
		{
			v = predict_probability(model_, x, prob_estimates);
			ptr_predict_label[instance_index] = v;
			for(i=0;i<nr_class;i++)
				ptr_prob_estimates[instance_index + i * testing_instance_number] = prob_estimates[i];
		}
		else
		{
			double *dec_values = Malloc(double, nr_class);
			v = predict(model_, x);
			ptr_predict_label[instance_index] = v;

			predict_values(model_, x, dec_values);
			for(i=0;i<nr_classifier;i++)
				ptr_dec_values[instance_index + i * testing_instance_number] = dec_values[i];
		}

		if(v == target)
			++correct;
		++total;
	}
	mexPrintf("Accuracy = %g%% (%d/%d)\n", (double)correct/total*100,correct,total);

	// return accuracy, mean squared error, squared correlation coefficient
	plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL);
	ptr = mxGetPr(plhs[1]);
	ptr[0] = (double)correct/total*100;

	free(x);
	if(prob_estimates != NULL)
		free(prob_estimates);
}

void exit_with_help()
{
	mexPrintf(
	"Usage: [predicted_label, accuracy, decision_values/prob_estimates] = predict(testing_label_vector, testing_instance_matrix, model, 'liblinear_options')\n"
	"liblinear_options:\n"
	"-b probability_estimates: whether to predict probability estimates, 0 or 1 (default 0)\n"
	);
}

void mexFunction( int nlhs, mxArray *plhs[],
		 int nrhs, const mxArray *prhs[] )
{
	int prob_estimate_flag = 0;
	struct model *model_;

	if(nrhs > 4 || nrhs < 3)
	{
		exit_with_help();
		fake_answer(plhs);
		return;
	}

	if(mxIsStruct(prhs[2]))
	{
		const char *error_msg;

		// parse options
		if(nrhs==4)
		{
			int i, argc = 1;
			char cmd[CMD_LEN], *argv[CMD_LEN/2];

			// put options in argv[]
			mxGetString(prhs[3], cmd,  mxGetN(prhs[3]) + 1);
			if((argv[argc] = strtok(cmd, " ")) != NULL)
				while((argv[++argc] = strtok(NULL, " ")) != NULL)
					;

			for(i=1;i<argc;i++)
			{
				if(argv[i][0] != '-') break;
				if(++i>=argc)
				{
					exit_with_help();
					fake_answer(plhs);
					return;
				}
				switch(argv[i-1][1])
				{
					case 'b':
						prob_estimate_flag = atoi(argv[i]);
						break;
					default:
						mexPrintf("unknown option\n");
						exit_with_help();
						fake_answer(plhs);
						return;
				}
			}
		}

		model_ = Malloc(struct model, 1);
		error_msg = matlab_matrix_to_model(model_, prhs[2]);
		if(error_msg)
		{
			mexPrintf("Error: can't read model: %s\n", error_msg);
			destroy_model(model_);
			fake_answer(plhs);
			return;
		}

		if(prob_estimate_flag)
		{
			if(model_->param.solver_type==L2LOSS_SVM)
			{
				mexPrintf("probability output for L2LOSS_SVM is not supported yet\n");
				prob_estimate_flag=0;
			}
		}
		do_predict(plhs, prhs, model_, prob_estimate_flag);
		// destroy model_
		destroy_model(model_);
	}
	else
	{
		mexPrintf("model file should be a struct array\n");
		fake_answer(plhs);
	}

	return;
}