# Imagen para convertir modelos YOLOv9 a ONNX
FROM python:3.10-slim

# Instalar dependencias de sistema
RUN apt-get update && apt-get install -y     git     libgl1-mesa-glx     libglib2.0-0     && rm -rf /var/lib/apt/lists/*

# Configurar directorio de trabajo
WORKDIR /app

# Clonar YOLOv9 (WongKinYiu)
RUN git clone https://github.com/WongKinYiu/yolov9.git /app

# Instalar dependencias de Python
RUN pip install --no-cache-dir torch torchvision --index-url https://download.pytorch.org/whl/cpu &&     pip install --no-cache-dir onnx onnx-simplifier onnxruntime-openvino requests pyyaml tqdm matplotlib pandas seaborn psutil setuptools

# Parchear experimental.py para PyTorch 2.6+ (weights_only=False)
RUN sed -i 's/torch.load(ckpt, map_location=device)/torch.load(ckpt, map_location=device, weights_only=False)/g' models/experimental.py

# Script para descarga automatica y conversion
# Uso: docker run -v $(pwd):/app/export yolov9-exporter python export.py --weights yolov9-s.pt --include onnx --imgsz 320 320
ENTRYPOINT ["python", "export.py"]
CMD ["--help"]
