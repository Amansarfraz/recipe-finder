import httpx
from fastapi import APIRouter, HTTPException, Response
from fastapi.responses import StreamingResponse

router = APIRouter(prefix="/image-proxy", tags=["images"])

ALLOWED_HOST = "img.spoonacular.com"


@router.get("")
async def proxy_image(url: str):
    """
    Fetches an external image server-side and streams it back through our
    own API. This exists because Flutter Web's CanvasKit renderer needs
    CORS-allowed responses to draw images on canvas, and Spoonacular's CDN
    doesn't send CORS headers. Since our own FastAPI app already has
    CORSMiddleware enabled, images served through this endpoint pick up
    proper CORS headers automatically.
    """
    if ALLOWED_HOST not in url:
        raise HTTPException(status_code=400, detail="Only Spoonacular image URLs are allowed")

    async with httpx.AsyncClient() as client:
        try:
            resp = await client.get(url, timeout=10.0)
            resp.raise_for_status()
        except Exception:
            raise HTTPException(status_code=502, detail="Could not fetch image")

    return Response(
        content=resp.content,
        media_type=resp.headers.get("content-type", "image/jpeg"),
    )