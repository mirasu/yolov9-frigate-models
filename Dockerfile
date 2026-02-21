# Dockerfile para Modelos YOLOv9 (320x320)
FROM alpine:latest

LABEL maintainer="mirasu"
LABEL description="Contenedor de modelos YOLOv9 exportados a ONNX (320x320) para Frigate"

# Crear directorio para los modelos
WORKDIR /models

# Copiar los modelos ONNX
COPY models/*.onnx /models/

# Documentación básica
RUN echo "Modelos YOLOv9 exportados con éxito." > /models/README.txt

# El contenedor es solo un almacén de datos (Data Volume Container)
CMD ["ls", "-R", "/models"]
