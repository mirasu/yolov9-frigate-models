# Configuración de YOLOv9 para Frigate

Has compilado con éxito tres variantes del modelo **YOLOv9** a formato ONNX.

## Ubicación de los archivos
- **YOLOv9-E (Extended/Power):** `/home/mirasu/yolov9-p.onnx` (265 MB) - *Máxima precisión*
- **YOLOv9-S (Small):** `/home/mirasu/yolov9-s.onnx` (39 MB) - *Equilibrio*
- **YOLOv9-T (Tiny):** `/home/mirasu/yolov9-t.onnx` (9 MB) - *Máxima velocidad*

## Integración en Frigate (`config.yml`)

Elige el modelo según tu hardware. El modelo **Tiny** es excelente para CPUs poco potentes, mientras que el **Extended (p)** es ideal si tienes un procesador moderno o iGPU.

### Ejemplo de configuración
```yaml
detectors:
  ov:
    type: openvino
    device: AUTO

model:
  path: /config/model_cache/yolov9-s.onnx # Cambia a -p o -t según prefieras
  input_tensor: nchw
  input_pixel_format: rgb
  width: 640
  height: 640
  labelmap_path: /config/model_cache/coco_labels.txt
```

### Diferencias de rendimiento
- **Tiny (t):** Muy bajo consumo de CPU, ideal para muchas cámaras.
- **Small (s):** Buen punto medio para detección de personas/objetos pequeños.
- **Extended (p):** Pesado, pero con la mejor detección disponible en YOLOv9.


### Notas Importantes
1. **Labels:** YOLOv9 usa las 80 clases de COCO. Si no tienes el archivo de etiquetas, puedes crearlo con la lista estándar de COCO (person, bicycle, car, motorcyle, etc.).
2. **Dimensiones:** El modelo se exportó con una resolución de **640x640**. Asegúrate de que coincida en la configuración.
3. **Rutas:** Recuerda mapear el volumen en Docker para que Frigate vea el archivo `.onnx` (ejemplo: `-v /home/mirasu/yolov9-p.onnx:/config/model_cache/yolov9-p.onnx:ro`).

### Conversión a TensorRT (.engine)
Si decides usar una GPU Nvidia, puedes convertir el ONNX a un engine optimizado usando el script proporcionado:
```bash
python3 /workspace/convert_onnx_to_trt.py --onnx /home/mirasu/yolov9-p.onnx --output /home/mirasu/yolov9-p.engine
```
Y luego cambia el detector en Frigate a `tensorrt`.

---

## 🐳 Uso con Docker

Si prefieres usar la imagen Docker para distribuir o servir los modelos, sigue estos pasos:

### 1. Construir la imagen
Desde la raíz del repositorio:
```bash
docker build -t yolov9-models-frigate:latest .
```

### 2. Ejecutar y verificar
La imagen está basada en Alpine y simplemente contiene los archivos en `/models`.
```bash
docker run --rm yolov9-models-frigate:latest ls -lh /models
```

### 3. Extraer modelos desde Docker (opcional)
Si necesitas sacar un modelo específico de la imagen construida:
```bash
docker run --rm -v $(pwd):/output yolov9-models-frigate:latest cp /models/yolov9-s-320.onnx /output/
```

---

## 🚀 Notas sobre el Hardware
- **CPU / OpenVINO:** Recomendado usar los modelos de **320px** para menor latencia.
- **GPU / TensorRT:** Los modelos de **640px** ofrecen la mejor precisión si tienes potencia suficiente.

---

## 🛠️ Herramienta de Conversión (YOLOv9 a ONNX)

Si necesitas exportar tus propios modelos o resoluciones personalizadas, ahora incluimos un entorno de exportación completo en la carpeta `exporter/`.

### 1. Construir la imagen de conversión
```bash
cd exporter
docker build -t yolov9-exporter .
```

### 2. Exportar un modelo nuevo
Este comando descarga automáticamente los pesos (.pt) de YOLOv9 y los convierte a ONNX:

```bash
# Ejemplo: Exportar YOLOv9-c con entrada de 416px
docker run --rm -v $(pwd):/app/export yolov9-exporter \
    --weights yolov9-c.pt \
    --include onnx \
    --imgsz 416 416
```

*El modelo resultante aparecerá en tu carpeta local `exporter/`.*

### Características del Exportador:
- Basado en **Python 3.10** y **PyTorch (CPU)**.
- Incluye el parche necesario para cargar pesos en versiones modernas de PyTorch (`weights_only=False`).
- Repositorio oficial de **WongKinYiu/yolov9** pre-instalado.
