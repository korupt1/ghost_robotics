//@author: raul
//@tags: Simple Movement Model & Landing
//@credits: vux

#include "particle_struct.fxh"

float VelMax;
float AccMax;
int TargetCount;
bool Landing;
int Index_LandingPos;
float BreakDown;
StructuredBuffer<float3> TargetBuffer;
StructuredBuffer<float3> LandingCoords_1;
StructuredBuffer<float3> LandingCoords_2;

//Gloab Methods--------------------------------------

float Truncater1D(float X, float Y)
{
if(X > 0) 
	{
	return min(X, Y);
	}
	else
	{
	return max(X, (Y*(-1)));
	}
}

float3 Truncater3D(float3 Geschw, float Maximum)
{
	return normalize(Geschw)*Truncater1D(length(Geschw), Maximum);
}
//----------------------------------------------------

RWStructuredBuffer<particle> Output : BACKBUFFER;

//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(128, 1, 1)]
void CSConstantForce( uint3 DTid : SV_DispatchThreadID )
{
		//Load Data from Buffer-----------------
		float3 p = Output[DTid.x].pos;
		float3 v = Output[DTid.x].vel;
		float3 a = Output[DTid.x].acc;
		float mass = Output[DTid.x].mass;
		//--------------------------------------
		float3 DirectionsTarget = float3(0,0,0);
		if (Landing)
		{
			float3 LandingCoords = float3(0,0,0);
			
			switch (Index_LandingPos)
			{
				case 0:
				LandingCoords = LandingCoords_1[DTid.x];
				break;
				
				case 1:
				LandingCoords = LandingCoords_2[DTid.x];
				break;
			}
			 
			//Calc NewForce Landing-----------------------------	
			float3 Vel2Target = normalize(LandingCoords - p) * Truncater1D( length(LandingCoords - p)* BreakDown,VelMax ) ;
			float3 Acc2Target = normalize(Vel2Target - v);
			float AccLenght = length(Acc2Target);
			float dist2Target = distance(p,LandingCoords);
			float Lerpdist2Target = min((dist2Target /0.1),1);
			
			float3 NewAcc = ((Acc2Target * Truncater1D(AccLenght,AccMax)) / mass);
			v = lerp( float3(0,0,0) , (Truncater3D( (v + NewAcc), VelMax)) ,Lerpdist2Target);
			DirectionsTarget = NewAcc * 0.8;
		}
		else
		{
			//Define Nearest Target Search Variables
			float MinDist = 10000;
			float3 Target = float3(0,0,0);
			//Get nearest Target
			for (int i = 0; i < TargetCount; i++) 
			{
				float Dist = distance(TargetBuffer[i],p);
				if (Dist < MinDist)
					{
						MinDist = Dist;
						Target = TargetBuffer[i];
					}
			}
			//Calc Target NewForce-----------------------------
			DirectionsTarget = Target - p;
			float Force = length(DirectionsTarget);
			DirectionsTarget = normalize(DirectionsTarget);
			DirectionsTarget = ((DirectionsTarget * Truncater1D(Force,AccMax))/mass);
			//Calc Vel--------------------------------------
			v = Truncater3D((DirectionsTarget + v),VelMax);
		}
		
		//Write Data to Buffer------------------
		Output[DTid.x].acc += DirectionsTarget;
		Output[DTid.x].vel = v;
		//--------------------------------------
}

//==============================================================================
//TECHNIQUES ===================================================================
//==============================================================================

technique11 MovementModel_Simple
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSConstantForce() ) );
	}
}
