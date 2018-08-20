
struct particle
{
	float3 pos;
	float3 acc;
	float3 vel;		
	int age;	
};
float gravity = 0.0;

bool reset;


// buffer which holds particle objects
RWStructuredBuffer<particle> Output : BACKBUFFER;

//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(128, 1, 1)]
void CSConstantForce( uint3 index : SV_DispatchThreadID )
{
	
	// reset particle properties
	if (reset)
	{
		Output[index.x].pos = float3(-1000,-1000,1000);
		Output[index.x].vel = 0;
		Output[index.x].age = 0;
	}
	
	
	
		float3 velocity = Output[index.x].acc;
//		//Save the new Velocity in Buffer
		Output[index.x].vel += velocity;
//		//Apply Velocity to Position
		Output[index.x].pos += Output[index.x].vel;	
//		//increment Age
		Output[index.x].age ++;
//		// stop accumulating forces
		Output[index.x].acc *=0;	
	
	Output[index.x].pos.y += gravity;
}

technique10 World
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSConstantForce() ) );
	}
}




