package taurine.tests.math;
import taurine.math.Geom.*;
import taurine.math.*;
import utest.Assert;

class QuatTests
{
	public function new()
	{
	}

	//https://github.com/toji/gl-matrix/blob/master/spec/gl-matrix/quat-spec.js
	public function test_quats()
	{
		var out, quatA, quatB, id, result, oldA, oldB;
		var arr:QuatArray, v:Vec3, deg90 = new Rad(Math.PI/2);
		function reset()
		{
			v = vec(1,1,-1);
			arr = quat(
					[-1,-1,-1,-1], //don't let quatA be the index 0 otherwise we can miss some errors
					quatA = [1,2,3,4],
					quatB = [5,6,7,8],
					out = [0,0,0,0],
					oldA = [1,2,3,4],
					oldB = [5,6,7,8],
					id = [0,0,0,1]
			);
		}

		inline function eq(?quat1:QuatArray, idx:Int, quat:QuatArray, idx2:Int=0,?pos:haxe.PosInfos)
		{
			if (quat1 == null) quat1 = arr;
			Assert.isTrue(quat1.eq(idx, quat, idx2),pos);
		}
		reset();
		//basics:
		eq(0,arr,0);
		eq(quatA,arr,oldA);
		eq(quatB,arr,oldB);
		Assert.isFalse(arr.eq(quatA,arr,quatB));
		Assert.isFalse(arr.eq(quatB,arr,quatA));
		Assert.isFalse(arr.eq(id,arr,quatA));
		Assert.isFalse(arr.eq(id,arr,out));

		//slerp
		result = arr.slerp(id, quat(0,1,0,0), 0, .5, arr, out);
		Assert.equals(arr, result);
		eq(out,quat(0,.707106,0,.707106));
		eq(id,new Quat());
		//a==b
		result = arr.slerp(id, new Quat(), 0, .5, arr, out);
		Assert.equals(arr,result);
		eq(out,quat(0,0,0,1));
		eq(id,new Quat().identity());
		//theta == 180
		var a = new Quat(1,0,0,0).rotateX(Math.PI);
		result = new Quat(1,0,0,0).slerp(a,1);
		eq(result,0,quat(0,0,0,-1));
		//where a == -b
		result = quat(1,0,0,0).slerp(quat(-1,0,0,0), .5);
		eq(result,0,quat(1,0,0,0));

		//rotateX
		reset();
		result = arr.rotateX(id,deg90,arr,out);
		Assert.equals(result,arr);
		var v1 = vec(0,0,-1).array().transformQuat(0, arr,out).first();
		Assert.isTrue(v1.eq(vec(0,1,0)));

		//rotateY
		reset();
		result = arr.rotateY(id,deg90,arr,out);
		Assert.equals(result,arr);
		var v1 = vec(0,0,-1).array().transformQuat(0, arr,out).first();
		Assert.isTrue(v1.eq(vec(-1,0,0)));

		//rotateZ
		reset();
		result = arr.rotateZ(id,deg90,arr,out);
		Assert.equals(result,arr);
		var v1 = vec(0,1,0).array().transformQuat(0, arr,out).first();
		trace(v1,vec(-1,0,0));
		Assert.isTrue(v1.eq(vec(-1,0,0)));

		//fromMat3
		//legacy
		var matr = mat3(1,0,0, 0,0,-1, 0,1,0);
		result = arr.fromMat3(out,matr,0);
		Assert.equals(result,arr);
		eq(out,quat(.707106,0,0,0.707106));
		//where trace > 0
		matr = mat3(1,0,0, 0,0,-1, 0,1,0);
		result = arr.fromMat3(out,matr,0);
		Assert.equals(result,arr);
		v1 = vec(0,1,0).array().transformQuat(0, arr,out).first();
		Assert.isTrue(v1.eq(vec(0,0,1)));
		//from a normal matrix looking backward
		matr = new Mat3().fromMat4(new Mat4().lookAt(vec(0,0,0),vec(0,0,1),vec(0,1,0))).invert().transpose();
		result = arr.fromMat3(out,matr,0);
		v1 = vec(3,2,-1).transformQuat( arr.cloneAt(out).normalize() );
		Assert.isTrue(v1.eq( vec(3,2,-1).transformMat3(matr) ));
		Assert.equals(arr,result);
		//from a normal matrix looking left and upside down
		matr = new Mat3().fromMat4(new Mat4().lookAt(vec(0,0,0),vec(-1,0,0),vec(0,-1,0))).invert().transpose();
		result = arr.fromMat3(out,matr,0);
		v1 = vec(3,2,-1).transformQuat( arr.cloneAt(out).normalize() );
		Assert.isTrue(v1.eq( vec(3,2,-1).transformMat3(matr) ));
		Assert.equals(arr,result);
		//from a normal matrix looking upside down
		matr = new Mat3().fromMat4(new Mat4().lookAt(vec(0,0,0),vec(0,0,-1),vec(0,-1,0))).invert().transpose();
		result = arr.fromMat3(out,matr,0);
		v1 = vec(3,2,-1).transformQuat( arr.cloneAt(out).normalize() );
		Assert.isTrue(v1.eq( vec(3,2,-1).transformMat3(matr) ));
		Assert.equals(arr,result);
		reset();

		//setAxes
		var r = new Vec3();
		//given opengl defaults
		var view = vec(0,0,-1), up = vec(0,1,0), right = vec(1,0,0);
		result = arr.setAxes(out,view,0,right,0,up,0);
		Assert.equals(result,arr);
		eq(out,arr,id);
		//legacy example
		right = vec(1,0,0); up = vec(0,0,1); view = vec(0,-1,0);
		result = arr.setAxes(out,view,0,right,0,up,0);
		eq(out,quat(0.707106, 0, 0, 0.707106));

		//rotationTo
		//right angle
		result = arr.rotationTov(out,vec(0,1,0),0,vec(1,0,0),0);
		eq(out,quat(0,0,-0.707106, 0.707106));
		//parallel
		result = arr.rotationTo(out, 0,1,0, 0,1,0);
		Assert.isTrue(
				vec(0,1,0).array().transformQuat(0, arr,out)
				.eq(0,vec(0,1,0),0));
		//vectors are opposed x
		result = arr.rotationTo(out, 1,0,0, -1,0,0);
		Assert.isTrue(
				vec(1,0,0).array().transformQuat(0, arr,out)
				.eq(0,vec(-1,0,0),0));
		//vectors are opposed y
		result = arr.rotationTo(out, 0,1,0, 0,-1,0);
		Assert.isTrue(
				vec(0,1,0).array().transformQuat(0, arr,out)
				.eq(0,vec(0,-1,0),0));
		//vectors are opposed z
		result = arr.rotationTo(out, 0,0,1, 0,0,-1);
		Assert.isTrue(
				vec(0,0,1).array().transformQuat(0, arr,out)
				.eq(0,vec(0,0,-1),0));

		//setAxisAngle
		result = arr.setAxisAngle(out, 1,0,0, Math.PI/2);
		Assert.equals(result,arr);
		eq(out,quat(0.707106, 0, 0, 0.707106));

		//mul
		reset();
		result = arr.mul(quatA, arr,quatB, arr,out);
		eq(out, quat(24,48,48,-6));
		eq(quatA, quat(1,2,3,4));
		eq(quatB, quat(5,6,7,8));
		reset();
		result = arr.mul(quatA, arr,quatB);
		eq(quatA, quat(24,48,48,-6));
		eq(quatB, quat(5,6,7,8));
		reset();
		result = arr.mul(quatA, arr,quatB, arr,quatB);
		eq(quatA, quat(1,2,3,4));
		eq(quatB, quat(24,48,48,-6));
		reset();

		//length
		Assert.floatEquals( arr.lengthAt(quatA), Math.sqrt(30) );

		//normalize
		arr.setAt(quatA, 5,0,0,0);
		result = arr.normalize(quatA, arr,out);
		eq(quatA, quat(5,0,0,0));
		eq(out, quat(1,0,0,0));
		result = arr.normalize(quatA);
		eq(quatA, quat(1,0,0,0));

		//lerp
		reset();
		result = arr.lerp(quatA, arr,quatB, .5, arr,out);
		eq(out, quat(3,4,5,6));
		eq(quatA, arr,oldA);
		eq(quatB, arr,oldB);
		result = arr.lerp(quatA, arr,quatB, .5);
		eq(quatA, quat(3,4,5,6));
		eq(quatB, arr,oldB);
		reset();
		result = arr.lerp(quatA, arr,quatB, .5, arr,quatB);
		eq(quatB, quat(3,4,5,6));
		eq(quatA, arr,oldA);

		//invert
		reset();
		result = arr.invert(quatA, arr,out);
		eq(out, quat(-0.033333, -0.066666, -0.1, 0.133333));
		eq(quatA,arr,oldA);
		result = arr.invert(quatA);
		eq(quatA, quat(-0.033333, -0.066666, -0.1, 0.133333));

		//conjugate
		reset();
		result = arr.conjugate(quatA, arr,out);
		eq(out, quat(-1,-2,-3,4));
		eq(quatA,arr,oldA);
		result = arr.conjugate(quatA);
		eq(quatA, quat(-1,-2,-3,4));
	}
}
