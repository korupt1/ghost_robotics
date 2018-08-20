//define particle properties
#include "particle_struct.fxh"

bool reset;
float dragC;
float3 gravity;
// buffer which holds particle objects
RWStructuredBuffer<particle> Output : BACKBUFFER;

//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================
void ApplyForce (float3 force, uint index)
{
	//accumulating forces 
	force *= Output[index].mass;
	Output[index].acc += force;
}

[numthreads(128, 1, 1)]
void CSConstantForce( uint3 index : SV_DispatchThreadID )
{
	
	// reset particle properties
	if (reset)
	{
		Output[index.x].pos = float3(-1000,-1000,1000);
		Output[index.x].vel = 0;
		Output[index.x].age = 0;
		Output[index.x].mass = 0;
	}
		float3 drag = Output[index.x].vel * -1;
		drag *= dragC/10;

		ApplyForce(drag, index.x);
		ApplyForce(gravity * .001, index.x);

		float3 velocity = Output[index.x].acc;
		//Save the new Velocity in Buffer
		Output[index.x].vel += velocity;
		//Apply Velocity to Position
		Output[index.x].pos += Output[index.x].vel;	
		//increment Age
		Output[index.x].age ++;
		// stop accumulating forces
		Output[index.x].acc *=0;	
}





technique10 World
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSConstantForce() ) );
	}
}




