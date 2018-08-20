//define particle properties
#include "particle_struct.fxh"

float force;
int pCount;
// buffer which holds particle objects
RWStructuredBuffer<particle> Output : BACKBUFFER;

//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(128, 1, 1)]
void CSConstantForce( uint3 index : SV_DispatchThreadID )
{
	
	for (uint i=0; i < uint(pCount); i++)
	{
		
		if( index.x != i)
		{
			float3 dist = distance(Output[index.x].pos, Output[i].pos);
			
			//dist = normalize (dist);
			
			dist = min(dist, 15);
			dist = max(dist, 5);
			//if( dist >15)
			//	dist=15;
			//else if (dist<5)
			//	dist=5;
			
			dist = normalize(dist);
		    float3 f=saturate(1-dist*2);
	  		f=pow(f,force);
			
			float3 strength = (0.4 * f * Output[index.x].mass) / (dist * dist);
			dist *= strength;
	
			dist /= Output[index.x].mass;
			
			Output[index.x].acc += dist; 
			
		}
	}
	
}

technique10 Emitter
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSConstantForce() ) );
	}
}




