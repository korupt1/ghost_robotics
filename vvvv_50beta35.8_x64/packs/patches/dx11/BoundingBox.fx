//define particle properties
#include "particle_struct.fxh"


float width;
// buffer which holds particle objects
RWStructuredBuffer<particle> Output : BACKBUFFER;

//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(128, 1, 1)]
void CSConstantForce( uint3 index : SV_DispatchThreadID )
{
	

	
	if (Output[index.x].pos.x > width/2)
	{
		Output[index.x].pos.x = width/2;
		Output[index.x].vel.x *= -1; 
	}
	else if (Output[index.x].pos.x < -width/2)
	  {
	  	Output[index.x].vel.x *= -1;
	  	Output[index.x].pos.x = -width/2;
	  	
	  }
		if (Output[index.x].pos.y > width/2)
	{
		Output[index.x].pos.y = width/2;
		Output[index.x].vel.y *= -1; 
	}
	else if (Output[index.x].pos.y < -width/2)
	  {
	  	Output[index.x].vel.y *= -1;
	  	Output[index.x].pos.y = -width/2;
	  	
	  }
		if (Output[index.x].pos.z > width/2)
	{
		Output[index.x].pos.z = width/2;
		Output[index.x].vel.z *= -1; 
	}
	else if (Output[index.x].pos.z < -width/2)
	  {
	  	Output[index.x].vel.z *= -1;
	  	Output[index.x].pos.z = -width/2;
	  	
	  }
	  
	  	
	  
}

technique10 Emitter
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSConstantForce() ) );
	}
}




