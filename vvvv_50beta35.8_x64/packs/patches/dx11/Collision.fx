//@author: vux
//@help: standard constant shader
//@tags: color
//@credits: 

int pCount;
float radius;
//define particle properties
#include "particle_struct.fxh"


RWStructuredBuffer<particle> Output : BACKBUFFER;

//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================


bool CheckCollision (particle p0, particle p1)
{
	// get direction vector
	float3 dir = p0.pos - p1.pos;
	
	//sum radii
	float radii = pow(radius * 2,2);
	// sqrt of distance
	float sqr = (dir.x*dir.x) + (dir.y*dir.y) + (dir.z*dir.z);
	
	if (sqr <= radii)
		return true;
	else
		return false;
}

particle CalcCollisionForce (particle p0, particle p1)
{	
	// get direction vector
	float3 dir = p0.pos - p1.pos;
	// calc lengt of the vector
	float l = length(dir);
	
	// calc mtd
	float3 mtd = dir *(((radius+radius)-l)/l);
	
	// inverse mass
	float totalMass = 1/p0.mass + 1/p1.mass;
	
	p0.pos += mtd *((1/p0.mass) / totalMass);
	
	//impact speed
	float3 v = p0.vel - p1.vel;
	
	float vn = dot(v, normalize(mtd));
	
	if( vn > .0f)
		return p0;
	
	//collision impulse
	float i =(-(1.0f * vn) / totalMass);
	
	float3 impulse = normalize(mtd) * i;
	
	p0.vel += (impulse * (1/p0.mass));
    
    return p0;
}


[numthreads(128, 1, 1)]
void CSConstantForce( uint3 DTid : SV_DispatchThreadID )
{
	// run trough all particles for each particle
	for (uint i=0; i < uint(pCount) ; i++)
	{
		// if i ist not the particle itself calc collision
		if ( DTid.x != i)
			if(CheckCollision(Output[DTid.x], Output[i]))
				Output[DTid.x] = CalcCollisionForce(Output[DTid.x], Output[i]);
		
	}

}

technique10 Constant
{
	pass P0s
	{
	SetComputeShader( CompileShader( cs_5_0, CSConstantForce() ) );
	}
}




