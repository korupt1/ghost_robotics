StructuredBuffer<float3>BoundsMin;
StructuredBuffer<float3>BoundsMax;
StructuredBuffer<float4> sbPosition;
RWStructuredBuffer<float4> rwbuffer : BACKBUFFER;
int elementcount;

int boxCount;


[numthreads(32, 1, 1)]
void CS( uint3 i : SV_DispatchThreadID)
{ 
	float4 p = sbPosition[i.x];
	rwbuffer[i.x].xyz = p.xyz;
	float hit = 0;
	for (int j = 0; j<boxCount; j++) {	 
	if ((p.x > BoundsMin[j].x) 
	 && (p.x < BoundsMax[j].x)
	 && (p.y > BoundsMin[j].y)	
	 && (p.y < BoundsMax[j].y)
	 && (p.z > BoundsMin[j].z)		
	 && (p.z < BoundsMax[j].z)) { 
 		hit = j+1;
	}	else {

	}
		rwbuffer[i.x].w = hit;	
	}
	
		
	 	
	 
	
}

technique11 Process
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}







