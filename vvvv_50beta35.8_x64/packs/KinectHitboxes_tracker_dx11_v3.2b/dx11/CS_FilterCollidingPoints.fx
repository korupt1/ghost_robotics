StructuredBuffer<float3>BoundsMin;
StructuredBuffer<float3>BoundsMax;
StructuredBuffer<float4> sbPosition;

int elementcount;

AppendStructuredBuffer<float3> AppendPositionBuffer : BACKBUFFER;


[numthreads(32, 1, 1)]
void CS( uint3 i : SV_DispatchThreadID)
{ 
	//Safeguard if we don't use a multiple
	if (i.x >=  elementcount) { return;}

	if ((sbPosition[i.x].w> 0.99)&&(sbPosition[i.x].w< 1.01)) {
		AppendPositionBuffer.Append(sbPosition[i.x].xyz);	
		
	}
}

technique11 Process
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CS() ) );
	}
}







