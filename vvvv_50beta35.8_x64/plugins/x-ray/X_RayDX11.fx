//@author: vux
//@help: standard constant shader
//@tags: color
//@credits: 

//transforms
float4x4 tW : WORLD;
float Alpha <float uimin=0.0; float uimax=1.0;> = 1; 
float4 cAmb <bool color=true;String uiname="Color";> = { 1.0f,1.0f,1.0f,1.0f };
float4x4 tColor <string uiname="Color Transform";>;
float4x4 tVP : LAYERVIEWPROJECTION;
float4x4 tV: VIEW;
float4x4 tWVP: WORLDVIEWPROJECTION;
float4x4 tWV : WORLDVIEW;

//Tweak
float Tweak  <string uiname="Tweak";> = 0.5 ;

struct vsInput
{
    float4 posObject : POSITION;
	float4 normalObject : NORMAL;
};


struct psInput
{
    float4 posScreen : SV_Position;
    float4 t0           : TEXCOORD0;
    float4 t1		: TEXCOORD1;
};


psInput VS(vsInput input)
{
	psInput output;
	
	float4 Normals = float4(input.normalObject.x,input.normalObject.y,input.normalObject.z,0) ;
	
	output.posScreen = mul(input.posObject,tWVP);
	output.t0 =  mul(input.posObject, tWV);
	output.t1 = mul(Normals, tWVP);
	return output;
}



float4 PS(psInput input): SV_Target
{

	float  opac = dot(normalize(input.t0), normalize(input.t1));
    
           opac = abs(opac);
           opac = 1-pow(opac, Tweak);

    float4 col;
    
           col.rgb = opac * cAmb;
           col.a   = opac ;
	
	
	
	
    return col;
}





technique11 ConstantNoTexture
{
	pass P0
	{
		SetVertexShader( CompileShader( vs_4_0, VS() ) );
		SetPixelShader( CompileShader( ps_4_0, PS() ) );
	}
}





