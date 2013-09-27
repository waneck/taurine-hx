package taurine.tests.math;
import taurine.math.Geom.*;
import taurine.math.*;
import utest.Assert;

class MatrixTests
{
	public function new()
	{
	}

	//https://github.com/toji/gl-matrix/blob/master/spec/gl-matrix/mat2d-spec.js
	public function test_mat_2d()
	{
		var out, matA, matB, identity, result, oldA, oldB;
		var arr:Mat2DArray;
		function reset()
		{
			arr = mat2d(
					[-1,-1,-1,-1,-1,-1], //don't let matA be the index 0 otherwise we can miss some errors
					matA = [1, 2,
									3, 4,
									5, 6],

					oldA = [1, 2,
									3, 4,
									5, 6],

					matB = [7, 8,
									9, 10,
									11, 12],

					oldB = [7, 8,
									9, 10,
									11, 12],

					out =  [0, 0,
									0, 0,
									0, 0],

					identity = [1, 0,
											0, 1,
											0, 0]
			);
		}

		inline function eq(idx:Int, mat:Mat2DArray, idx2:Int=0,?pos:haxe.PosInfos)
		{
			Assert.isTrue(arr.eq(idx, mat, idx2),pos);
		}
		reset();
		//basics:
		eq(0,arr,0);
		eq(matA,arr,oldA);
		eq(matB,arr,oldB);
		Assert.isFalse(arr.eq(matA,arr,matB));
		Assert.isFalse(arr.eq(matB,arr,matA));
		Assert.isFalse(arr.eq(identity,arr,matA));
		Assert.isFalse(arr.eq(identity,arr,out));

		//create
		eq(identity, new Mat2D(), 0);
		Assert.equals(6, new Mat2D().getData().length);

		//clone
		var out1 = new Mat2D();
		var result = arr.copyTo(matA, out1, 0);

		eq(matA, out1, 0);
		Assert.notEquals(arr, out1);
		Assert.equals(out1, result);
		eq(matA, arr.copyTo(matA, new Mat2D(), 0), 0);

		//in-place copy
		result = arr.copyTo(matA, arr, out);
		eq(matA, arr, out);
		Assert.equals(arr,result);

		//identity
		result = arr.identity(out);
		Assert.equals(result,arr); //returns itself
		eq(identity,arr,out);

		result = out1.identity();
		Assert.equals(result, out1);
		eq(identity,result,0);

		//invert
		//separate output matrix
		result = arr.invert(matA, out1, 0);
		Assert.equals(out1,result);
		Assert.isTrue(out1.eq(mat2d(-2, 1, 1.5, -0.5, 1, -2)));
		eq(matA,arr,oldA);
		//same output
		result = arr.invert(matA,arr,matA);
		Assert.equals(arr,result);
		eq(matA, mat2d(-2, 1, 1.5, -0.5, 1, -2), 0);
		reset();

		//determinant
		Assert.equals(arr.det(matA), -2);

		//multiply
		//separate output matrix
		result = arr.mul(matA, arr, matB, out1, 0);
		Assert.equals(result, out1);
		Assert.isTrue(out1.eq(mat2d(25, 28, 57, 64, 100, 112)));
		eq(matA,arr,oldA);
		eq(matB,arr,oldB);
		//matA is output
		result = arr.mul(matA, arr, matB, arr, matA);
		Assert.equals(result, arr);
		eq(matA,mat2d(25, 28, 57, 64, 100, 112),0);
		eq(matB,arr,oldB);
		reset();
		//matB is output
		result = arr.mul(matA,arr,matB,arr,matB);
		Assert.equals(result,arr);
		eq(matB,mat2d(25, 28, 57, 64, 100, 112),0);
		eq(matA,arr,oldA);
		reset();

		//rotate
		//separate output
		result = arr.rotate(matA, Math.PI * .5, out1, 0);
		Assert.equals(result,out1);
		Assert.isTrue(out1.eq(mat2d(2, -1, 4, -3, 6, -5)));
		eq(matA,arr,oldA);
		//matA output
		result = arr.rotate(matA,Math.PI * .5, arr, matA);
		Assert.equals(result,arr);
		Assert.isTrue(arr.eq(matA,mat2d(2, -1, 4, -3, 6, -5),0));
		reset();
		//same output
		result = arr.rotate(matA,Math.PI * .5);
		Assert.equals(result,arr);
		Assert.isTrue(arr.eq(matA,mat2d(2, -1, 4, -3, 6, -5),0));
		reset();

		//scale
		var vecA = vec2([2,3]);
		//separate output
		result = arr.scalev(matA,vecA,out1,0);
		Assert.isTrue(out1.eq(mat2d(2, 6, 6, 12, 10, 18)));
		Assert.equals(result,out1);
		eq(matA,arr,oldA);
		Assert.isTrue(vecA.eq(vec2(2,3)));
		//same output
		result = arr.scalev(matA,vecA); //should be implicit
		Assert.equals(result,arr);
		eq(matA,mat2d(2, 6, 6, 12, 10, 18),0);
		Assert.isTrue(vecA.eq(vec2(2,3)));
		reset();

		//translate
		//separate
		result = arr.translatev(matA,vecA,out1,0);
		Assert.isTrue(out1.eq(mat2d(1, 2, 3, 4, 7, 9)));
		Assert.equals(result,out1);
		eq(matA,arr,oldA);
		//same
		result = arr.translatev(matA,vecA,arr,matA);
		eq(matA,mat2d(1, 2, 3, 4, 7, 9),0);
		Assert.equals(result,arr);
	}
}
