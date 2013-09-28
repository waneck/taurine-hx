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
	public function test_mat2d()
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
		//operator overloading
		arr.copyTo(matA,out1,0);
		var out2 = new Mat2D();
		arr.copyTo(matB,out2,0);
		var out3 = out1 * out2;
		Assert.notEquals(out3,out1);
		Assert.notEquals(out3,out2);
		eq(matA,out1,0);
		eq(matB,out2,0);
		Assert.isTrue(out3.eq(mat2d(25, 28, 57, 64, 100, 112)));

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

	public function test_mat3()
	{
		var out, matA, matB, identity, result, oldA, oldB;
		var arr:Mat3Array;
		function reset()
		{
			arr = mat3(
					[-1,-1,-1,-1,-1,-1,-1,-1,-1], //don't let matA be the index 0 otherwise we can miss some errors
					matA = [1, 0, 0,
									0, 1, 0,
									1, 2, 1],

					oldA = [1, 0, 0,
									0, 1, 0,
									1, 2, 1],

					matB = [1, 0, 0,
									0, 1, 0,
									3, 4, 1],

					oldB = [1, 0, 0,
									0, 1, 0,
									3, 4, 1],

					out =  [0, 0, 0,
									0, 0, 0,
									0, 0, 0],

					identity = [1, 0, 0,
											0, 1, 0,
											0, 0, 1]
			);
		}

		inline function eq(?mat1:Mat3Array, idx:Int, mat:Mat3Array, idx2:Int=0,?pos:haxe.PosInfos)
		{
			if(mat1 == null) mat1 = arr;
			Assert.isTrue(mat1.eq(idx, mat, idx2),pos);
		}
		reset();
		//basics
		eq(0,arr,0);
		eq(matA,arr,oldA);
		eq(matB,arr,oldB);
		Assert.isFalse(arr.eq(matA,arr,matB));
		Assert.isFalse(arr.eq(matB,arr,matA));
		Assert.isFalse(arr.eq(identity,arr,matA));
		Assert.isFalse(arr.eq(identity,arr,out));

		//normal from mat4
		var m1 = mat4([-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1], //index != 0 to catch more errors
									[1,0,0,0,
									 0,1,0,0,
									 0,0,1,0,
									 0,0,0,1]);
		var result = arr.normalFromMat4(out,m1,1);
		Assert.equals(result,arr);
		//translation
		m1.translatev(1,vec3(2,4,6));
		m1.rotateX(1,Math.PI/2);
		result = arr.normalFromMat4(out,m1,1);
		Assert.equals(result,arr);
		eq(out,mat3(1,0,0,
								0,0,1,
								0,-1,0));
		//scale
		m1.scale(1, 2,3,4);
		result = arr.normalFromMat4(out,m1,1);
		eq(out,mat3(.5, 0,   0,
								 0, 0,   0.333333,
								 0, -.25,0));
		reset();

		//fromQuat
		var q = quat(0, -0.7071067811865475, 0, 0.7071067811865475);
		result = arr.fromQuat(out,q,0);
		Assert.equals(result,arr);
		Assert.isTrue(vec(0,0,-1).array().transformMat3(0, arr, out).eq(0,vec(-1,0,0),0));
		reset();

		//fromMat4
		result = arr.fromMat4(out, mat4([-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1],
																		[1 ,2 ,3 ,4 ,
																		 5 ,6 ,7 ,8 ,
																		 9 ,10,11,12,
																		 13,14,15,16]), 1);
		Assert.equals(result,arr);
		eq(out,mat3(1,2,3,
								5,6,7,
								9,10,11));
		//scale
		result = arr.scalev(matA, vec(2,2), arr, out);
		Assert.equals(result,arr);
		eq(out,mat3(2,0,0,
								0,2,0,
								1,2,1));
		eq(matA,arr,oldA);

		//create
		result = new Mat3();
		Assert.notEquals(result,arr);
		eq(identity, result, 0);

		//clone
		result = arr.cloneAt(matA);
		Assert.notEquals(result,arr);
		eq(matA, result, 0);

		//copy
		result = arr.copy();
		Assert.notEquals(result,arr);
		eq(matA,result,matA);
		eq(out,result,out);
		eq(identity,result,identity);

		//identity
		result = arr.identity(out);
		Assert.equals(result,arr);
		eq(out,arr,identity);

		//transpose
		//separate output matrix
		reset();
		result = arr.transpose(matA,new Mat3(),0);
		Assert.notEquals(result,arr);
		Assert.isTrue(result.eq(0,mat3(
					1,0,1,
					0,1,2,
					0,0,1),0));
		eq(matA,arr,oldA);
		//same output
		result = arr.transpose(matA);
		Assert.equals(arr,result);
		eq(matA,mat3(
					1,0,1,
					0,1,2,
					0,0,1));
		reset();

		//invert
		//seperate output
		result = arr.invert(matA,new Mat3(),0);
		Assert.notEquals(result,arr);
		Assert.isTrue(result.eq(0,mat3(
					1,0,0,
					0,1,0,
					-1,-2,1),0));
		eq(matA,arr,oldA);
		//same output
		result = arr.invert(matA);
		Assert.equals(result,arr);
		eq(matA,mat3(
					1,0,0,
					0,1,0,
					-1,-2,1));
		reset();

		//adjoint
		//separate output
		result = arr.adjoint(matA, new Mat3(),0);
		Assert.notEquals(result,arr);
		eq(result,0,mat3(
					1,0,0,
					0,1,0,
					-1,-2,1));
		eq(matA,arr,oldA);
		//same output
		result = arr.adjoint(matA);
		Assert.equals(result,arr);
		eq(matA,mat3(
					1,0,0,
					0,1,0,
					-1,-2,1));
		reset();

		//determinant
		var det = arr.determinant(matA);
		Assert.equals(det,1);

		//multiply
		//separate output
		result = arr.mul(matA,arr,matB,new Mat3(),0);
		Assert.notEquals(result,arr);
		eq(result,0,mat3(1,0,0, 0,1,0, 4,6,1));
		eq(matA,arr,oldA);
		eq(matB,arr,oldB);
		//matA output
		result = arr.mul(matA,arr,matB);
		Assert.equals(result,arr);
		eq(matA,mat3(1,0,0, 0,1,0, 4,6,1));
		eq(matB,arr,oldB);
		reset();
		//matB output
		result = arr.mul(matA,arr,matB,arr,matB);
		Assert.equals(result,arr);
		eq(matB,mat3(1,0,0, 0,1,0, 4,6,1));
		eq(matA,arr,oldA);
	}

	public function test_mat4()
	{
		var out, matA, matB, identity, result:Mat4Array, oldA, oldB;
		var arr:Mat4Array;
		function reset()
		{
			arr = mat4(
					[-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1], //don't let matA be the index 0 otherwise we can miss some errors
					// Attempting to portray a semi-realistic transform matrix
					matA = [1, 0, 0, 0,
									0, 1, 0, 0,
									0, 0, 1, 0,
									1, 2, 3, 1],

					matB = [1, 0, 0, 0,
									0, 1, 0, 0,
									0, 0, 1, 0,
									4, 5, 6, 1],

					out =  [0, 0, 0, 0,
									0, 0, 0, 0,
									0, 0, 0, 0,
									0, 0, 0, 0],

					identity = [1, 0, 0, 0,
											0, 1, 0, 0,
											0, 0, 1, 0,
											0, 0, 0, 1],

					oldA = [1, 0, 0, 0,
									0, 1, 0, 0,
									0, 0, 1, 0,
									1, 2, 3, 1],

					oldB = [1, 0, 0, 0,
									0, 1, 0, 0,
									0, 0, 1, 0,
									4, 5, 6, 1]

			);
		}

		inline function eq(?mat1:Mat4Array, idx:Int, mat:Mat4Array, idx2:Int=0,?pos:haxe.PosInfos)
		{
			if(mat1 == null) mat1 = arr;
			Assert.isTrue(mat1.eq(idx, mat, idx2),pos);
		}
		reset();
		//basics
		eq(0,arr,0);
		eq(matA,arr,oldA);
		eq(matB,arr,oldB);
		Assert.isFalse(arr.eq(matA,arr,matB));
		Assert.isFalse(arr.eq(matB,arr,matA));
		Assert.isFalse(arr.eq(identity,arr,matA));
		Assert.isFalse(arr.eq(identity,arr,out));

		//create
		eq(identity,new Mat4());

		//clone
		result = arr.cloneAt(matA);
		Assert.notEquals(result,arr);
		eq(matA, result, 0);

		//copy
		result = arr.copy();
		Assert.notEquals(result,arr);
		eq(matA,result,matA);
		eq(out,result,out);
		eq(identity,result,identity);

		//identity
		result = arr.identity(out);
		Assert.equals(result,arr);
		eq(out,arr,identity);

		//transpose
		//separate
		result = arr.transpose(matA,new Mat4(),0);
		Assert.notEquals(result,arr);
		eq(result, 0, mat4(1,0,0,1, 0,1,0,2, 0,0,1,3, 0,0,0,1));
		eq(matA,arr,oldA);
		//same
		result = arr.transpose(matA);
		Assert.equals(result,arr);
		eq(matA, mat4(1,0,0,1, 0,1,0,2, 0,0,1,3, 0,0,0,1));
		reset();

		//invert
		//separate
		result = arr.invert(matA, new Mat4(), 0);
		Assert.notEquals(result,arr);
		eq(result,0,mat4(1,0,0,0, 0,1,0,0, 0,0,1,0, -1,-2,-3,1));
		eq(matA,arr,oldA);
		//same
		result = arr.invert(matA);
		Assert.equals(result,arr);
		eq(matA,mat4(1,0,0,0, 0,1,0,0, 0,0,1,0, -1,-2,-3,1));
		reset();

		//adjoint
		//separate
		result = arr.adjoint(matA, new Mat4(),0);
		Assert.notEquals(result,arr);
		eq(result,0,mat4(1,0,0,0, 0,1,0,0, 0,0,1,0, -1,-2,-3,1));
		eq(matA,arr,oldA);
		//same
		result = arr.adjoint(matA);
		Assert.equals(result,arr);
		eq(matA,mat4(1,0,0,0, 0,1,0,0, 0,0,1,0, -1,-2,-3,1));
		reset();

		//det
		var det = arr.det(matA);
		Assert.equals(det,1);

		//mul
		//separate
		result = arr.mul(matA, arr, matB, new Mat4(), 0);
		Assert.notEquals(result,arr);
		eq(result,0,mat4(1,0,0,0, 0,1,0,0, 0,0,1,0, 5,7,9,1));
		eq(matA,arr,oldA);
		eq(matB,arr,oldB);
		//matA
		result = arr.mul(matA, arr, matB);
		Assert.equals(result,arr);
		eq(matA,mat4(1,0,0,0, 0,1,0,0, 0,0,1,0, 5,7,9,1));
		eq(matB,arr,oldB);
		reset();
		//matB
		result = arr.mul(matA, arr, matB, arr, matB);
		Assert.equals(result,arr);
		eq(matB,mat4(1,0,0,0, 0,1,0,0, 0,0,1,0, 5,7,9,1));
		eq(matA,arr,oldA);
		reset();

		//translate
		//separate
		result = arr.translatev(matA, vec(4,5,6), new Mat4(), 0);
		Assert.notEquals(result,arr);
		eq(result,0,mat4(1,0,0,0, 0,1,0,0, 0,0,1,0, 5,7,9,1));
		eq(matA,arr,oldA);
		eq(matB,arr,oldB);
		//matA
		result = arr.translatev(matA, vec(4,5,6));
		Assert.equals(result,arr);
		eq(matA,mat4(1,0,0,0, 0,1,0,0, 0,0,1,0, 5,7,9,1));
		eq(matB,arr,oldB);
		reset();
		//matB
		result = arr.translatev(matA, vec(4,5,6), arr, matB);
		Assert.equals(result,arr);
		eq(matB,mat4(1,0,0,0, 0,1,0,0, 0,0,1,0, 5,7,9,1));
		eq(matA,arr,oldA);
		reset();

		//scale
		//separate
		result = arr.scalev(matA, vec(4,5,6), new Mat4(), 0);
		Assert.notEquals(result,arr);
		eq(result,0,mat4(4,0,0,0, 0,5,0,0, 0,0,6,0, 1,2,3,1));
		eq(matA,arr,oldA);
		//matA
		result = arr.scalev(matA, vec(4,5,6));
		Assert.equals(result,arr);
		eq(matA,mat4(4,0,0,0, 0,5,0,0, 0,0,6,0, 1,2,3,1));
		reset();

		//rotate
		var rad = new Rad(Math.PI / 2);
		var axis = vec(1,0,0);
		//separate
		result = arr.rotatev(matA, rad, axis, new Mat4(), 0);
		eq(result,0,mat4(1,0,0,0, 0, rad.cos(), rad.sin(),0,  0,-rad.sin(), rad.cos(), 0,  1,2,3,1));
		Assert.notEquals(result,arr);
		eq(matA,arr,oldA);
		//matA
		result = arr.rotatev(matA, rad, axis);
		eq(matA,mat4(1,0,0,0, 0, rad.cos(), rad.sin(),0,  0,-rad.sin(), rad.cos(), 0,  1,2,3,1));
		Assert.equals(result,arr);
		reset();

		//rotateX
		//separate
		result = arr.rotateX(matA,rad,new Mat4(), 0);
		Assert.notEquals(result,arr);
		eq(result,0, mat4(1,0,0,0, 0,rad.cos(),rad.sin(),0, 0,-rad.sin(),rad.cos(),0, 1,2,3,1));
		eq(matA,arr,oldA);
		//same
		result = arr.rotateX(matA,rad);
		Assert.equals(result,arr);
		eq(matA, mat4(1,0,0,0, 0,rad.cos(),rad.sin(),0, 0,-rad.sin(),rad.cos(),0, 1,2,3,1));
		reset();


	}

}
