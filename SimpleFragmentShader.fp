#version 330 core

// Interpolated values from the vertex shaders
in vec2 fragmentUV;



// Values that stay constant
uniform sampler2D myTextureSamplerVolume;
uniform sampler2D myTextureSamplerNormal;

uniform float theta;
uniform int threshold;

// Ouput data
out vec3 color;


// Input: z coordinate of the point in the volume, between 0 and 1
// Output: grid coordinates (i,j) of the slice where the point lies, between (0,0) and (9,9)
// Warning: use the fonction "floor" to make sure that the coordinates of the slice are integer. For instance, for z = 0.823, the function should return (i=2,j=8) because the closest slice is the 82nd one.

vec2 slice_coordinate(float z)
{
      //rescale z
      float z2 = z*100.;

      //coordinate of the slice
      float j = floor(z2/10.);
      float i = floor(z2 - 10.*j);

      return vec2(i,j);
}

// Input: (x,y,z) coordinates of the point in the volume, between (0,0,0) and (1,1,1)
// Output: (u,v) coordinates of the pixel in the texture

vec2 pixel_coordinate(float x, float y, float z)
{
      vec2 sliceCoord = slice_coordinate(z);

      //coordinate of the pixel in the slice
      float u = x/10.;
      float v = y/10.;

      return vec2(u,v)+slice_coordinate(z)/10.;
}

void main()
{ 
      vec2 pixCoord;
      float x,y,z;
	  vec3 sum =vec3(0.0,0.0,0.0);
	  
	  /*  

      //extract one horizontal slice (x and y vary with fragment coordinates, z is fixed)
		 x = fragmentUV.x;
         y = fragmentUV.y;
   		z = 82./100.; //extract 82nd slice
		pixCoord = pixel_coordinate(x,y,z);
		color = texture(myTextureSamplerVolume, pixCoord).rgb;
		
	 */



    /*
      //Accumulate all horizontal slices 
      //... 
	  for(int i = 0; i <= 9; i++)
		for( int  j = 0; j <=9 ; j++)
		{
			pixCoord = vec2(i/10.0, j/10.0);
			sum += texture(myTextureSamplerVolume, fragmentUV/10.0 + pixCoord ).rgb;
		}
	  color = sum/100.0; 
	*/
	
	
	/*
      //extract one vertical slice (x and z vary with fragment coordinates, y is fixed)
      //...

	  x = fragmentUV.x;
	  y = 0.55 ;
	  z = fragmentUV.y;
	  pixCoord = pixel_coordinate(x,y,z);
	  color = texture(myTextureSamplerVolume, pixCoord).rgb;
   */
	




	/* 
 
      //Accumulate all vertical slices 
      //...
	  x = fragmentUV.x ;
	  z = fragmentUV.y ;
	  for(float i = 0.0; i < 256.0; i += 1.0) 
	  {
		y = i/256.0;
		pixCoord = pixel_coordinate(x,y,z);
		sum += texture(myTextureSamplerVolume, pixCoord).rgb;
	  }
	  sum /= 256.0;
	  color = sum;

  */



/* 
      //Accumulate all vertical slices after rotation by rotationAngle around the z axis
      //...

	x = fragmentUV.x;
    z = fragmentUV.y;

    mat2 rotation = mat2(
        vec2(cos(theta),  -sin(theta)),
        vec2(sin(theta),  cos(theta))
    );
    vec2 center = slice_coordinate(z)/10.0 + 0.05;

    for(int i = 0; i < 256; i++)
	{
        pixCoord = (pixel_coordinate(x,i/256.,z) - center) * rotation + center;
        sum += texture(myTextureSamplerVolume, pixCoord).rgb;
    }
    color = sum / 256.;


 */


/* 
     //Ray marching until density above a threshold (i.e., extract an iso-surface)
     //...
			x = fragmentUV.x;
			z = fragmentUV.y;
		 
			for(int j = 0; j <= 255; j++)
			{
				pixCoord = pixel_coordinate(x,j/256.,z);
				color = texture(myTextureSamplerVolume, pixCoord).r;
				if(color.x > threshold) {color = vec3(1.0,1.0,1.0); break;}
				else color = vec3(0.0,0.0,0.0); 
			}

*/

 /*
     //Ray marching until density above a threshold, display iso-surface normals
     //...

	x = fragmentUV.x;
	z = fragmentUV.y;

	color = vec3(0.0,0.0,0.0); 
	 
	for(int j = 0; j <= 255; j++)
	{
		
		pixCoord = pixel_coordinate(x, j/256.0, z);
		
		if(texture(myTextureSamplerVolume, pixCoord).r * 255 >= threshold) 
		{
			color = texture(myTextureSamplerNormal, pixCoord).rgb;  
			break;
		}

	}

 */

  
   /*
    //Ray marching until density above a threshold, display shaded iso-surface
    //...

	x = fragmentUV.x;
	z = fragmentUV.y;

	color = vec3(0.0,0.0,0.0) ; 

	vec3 L = vec3( 0.0, -1.0, 0.0 );
	
	vec3 V = vec3( 0.0, 0.0, -1.0 ); //Light and view directions are same

	for(int j = 0; j <= 255; j++)
	{
		
		pixCoord = pixel_coordinate(x, j/256.0, z);
		vec3 N =  normalize(texture (myTextureSamplerNormal, pixCoord).rgb ) ;

		float diffuse = max(dot(N,-L),0.);
		
		vec3 R = normalize(reflect(L,N)); 
		float specular = max(dot(R,V),0);


		if(texture(myTextureSamplerVolume, pixCoord).r * 255 >= threshold) 
		{
			//color = texture(myTextureSamplerNormal, pixCoord).rgb; 
			color = vec3(diffuse)  + vec3(pow(specular,64))* vec3(1.0,1.0,1.0);  
			break;
		}

	}
*/


	//Rotate the Volume, while keeping the light direction same as camera

	x = fragmentUV.x;
    z = fragmentUV.y;
	color = vec3(0.0,0.0,0.0); 
	vec3 L = vec3( 0.0, 0.0, -1.0 );
	
	vec3 V = L; //Light and view directions are same

	
		mat2 rotation = mat2(
			vec2(cos(theta),  -sin(theta)),
			vec2(sin(theta),  cos(theta))
		);

		vec2 center = slice_coordinate(z)/10.0 + 0.05;

		for(int i = 0; i < 256; i++)
		{
			pixCoord = (pixel_coordinate(x,i/256.,z) - center) * rotation + center;
			vec3 N =  normalize(texture (myTextureSamplerNormal, pixCoord).rgb ) ;

			float diffuse = max(dot(N,-L),0.);
		
			vec3 R = normalize(reflect(L,N)); 
			float specular = max(dot(R,V),0);


			if(texture(myTextureSamplerVolume, pixCoord).r * 255 >= threshold) 
			{
				//color = texture(myTextureSamplerNormal, pixCoord).rgb; 
				color = vec3(diffuse) * vec3(0.50754, 0.50754,0.50754) + vec3(pow(specular,16)) * vec3(1.0,1.0,1.0);  
				break;
			}

		}
	
		
}