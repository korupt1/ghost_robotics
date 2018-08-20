//define particle properties
#include "particle_struct.fxh"

float miny = 0.0f;

// buffer which holds particle objects
RWStructuredBuffer<particle> Output : BACKBUFFER;

//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(128, 1, 1)]
void CSConstantForce( uint3 index : SV_DispatchThreadID )
{
	
	if (Output[index.x].pos.y < miny)
	{
		Output[index.x].pos.y = miny;
		Output[index.x].vel.y *= -1;
	}
}

technique10 Emitter
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSConstantForce() ) );
	}
}




