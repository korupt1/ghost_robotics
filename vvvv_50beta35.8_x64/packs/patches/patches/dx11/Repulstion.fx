int pCount;
float radius;
float force;

//define particle properties
#include "particle_struct.fxh"

RWStructuredBuffer<particle> Output : BACKBUFFER;

//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(128, 1, 1)]
void CSConstantForce( uint3 DTid : SV_DispatchThreadID )
{
	// nested run through particles buffer within the shader loop
	for (uint i=0; i < uint(pCount) ; i++)
	{
		// calc the distance between all particles
		float dist = distance(Output[DTid.x].pos, Output[i].pos);
		
		// check if distance is smaller than radius
		if (dist < radius)
		{
			// compute a force which is based on distance
	  		float f = saturate(1-(dist*dist));
			
			// compute force depening on particle mass
			f *= (force * Output[DTid.x].mass) *.1;

			// compute directed acceleration based on direction
			Output[DTid.x].acc += (Output[DTid.x].pos - Output[i].pos) * f;	

		}
	}
}

technique10 Repulsion
{
	pass P0s
	{
	SetComputeShader( CompileShader( cs_5_0, CSConstantForce() ) );
	}
}




