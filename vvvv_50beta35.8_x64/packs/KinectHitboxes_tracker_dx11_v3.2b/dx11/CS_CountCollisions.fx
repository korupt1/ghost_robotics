//This is the buffer from the renderer
//Renderer automatically assigns BACKBUFFER semantic
RWStructuredBuffer<int> rwbuffer : BACKBUFFER;

StructuredBuffer<float3>BoundsMin;
StructuredBuffer<float3>BoundsMax;
StructuredBuffer<float4>PointsC;

int boxCount;
SamplerState mySampler : IMMUTABLE
{
    Filter = MIN_MAG_MIP_POINT;
    AddressU = Clamp;
    AddressV = Clamp;
};
[numthreads(64, 1, 1)]
void CS_Clear( uint3 i : SV_DispatchThreadID)
{ 
	rwbuffer[i.x] = 0;
}

[numthreads(1, 1, 1)]

void CS( uint3 i : SV_DispatchThreadID)
{ 

	float4 PointXYZW = PointsC[i.x];
		if (PointXYZW.w > 0) {
		for (int j = 0; j<boxCount; j++) {	
		if ((PointXYZW.x > BoundsMin[j].x) 
		 && (PointXYZW.x < BoundsMax[j].x)
		 && (PointXYZW.y > BoundsMin[j].y)	
		 && (PointXYZW.y < BoundsMax[j].y)
		 && (PointXYZW.z > BoundsMin[j].z)		
		 && (PointXYZW.z < BoundsMax[j].z)) { 
		 		uint oldval;
			InterlockedAdd(rwbuffer[j],1,oldval);		
			} else {
	
			}
		}			
	}
}

technique11 Process
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}

technique11 Clear
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS_Clear() ) );
	}
}




  