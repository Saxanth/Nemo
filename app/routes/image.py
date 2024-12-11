from enum import Enum
from PIL.Image import Image
import torch, os, uuid, tqdm
from typing import Literal, Optional, Tuple
from diffusers import FluxPipeline

class ImageSizeType(Enum):
    Small   = 256
    Medium  = 384
    Large   = 512
    XLarge  = 576

class ImageGenerator():
    def __init__(self, steps: int = 24) -> None:
        self.steps = steps
        self.uuid = uuid.uuid4()        
        self.generator = torch.Generator('cuda').manual_seed(
            torch.randint(low=1337, high=61337, size=[1])[0].item()
        )

        self.pipeline = FluxPipeline.from_pretrained(
            "black-forest-labs/FLUX.1-dev", 
            torch_dtype=torch.bfloat16, 
            device_map="balanced"
        )

        self.pipeline.set_progress_bar_config(disable=True)

    @property
    def get_unique_id(self): return self.uuid

    async def generate(self, prompt: str, size: Literal[ImageSizeType.Small, ImageSizeType.Medium, ImageSizeType.Large] = ImageSizeType.Small  ) -> Image :        
        return self.pipeline( 
            prompt=prompt,
            width=size.value,
            height=size.value,
            guidance_scale=3.5,
            num_inference_steps=self.steps,
            max_sequence_length=512,
            generator=self.generator,
        ).images[0]
    
modules = [ImageSizeType, ImageGenerator]