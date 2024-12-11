from typing import Optional, Tuple, Annotated
from fastapi import FastAPI, Body, Request
from fastapi.responses import ORJSONResponse, FileResponse
from routes import ImageGenerator, ImageSizeType
from pydantic import BaseModel, Field
from PIL.Image import Image
import os, datetime

app = FastAPI()
image_generator = ImageGenerator()
image_path = os.path.abspath('./.cache/images')

if not os.path.exists(image_path): os.makedirs(image_path)

class ImageGeneration(BaseModel):
    prompt: str
    image_size: ImageSizeType

@app.get('/', response_class=ORJSONResponse)
async def root():
    return ORJSONResponse( { "message": "success" }, status_code=200 )

@app.get("/image", response_class=FileResponse)
async def image_gen(generator: Annotated[ImageGeneration, Body(embed=True)]):    
    time = datetime.datetime.now(datetime.timezone.utc).strftime("%W-%H%M%S-%f")
    temp_path = os.path.join(image_path, f'{time}.png')
    image = await image_generator.generate(generator.prompt, generator.image_size)
    image.save(temp_path)

    return FileResponse(temp_path)