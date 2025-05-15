import os
import json
import xml.etree.ElementTree as ET

# Paths
xml_folder = "./new_annotations"
json_path = "./annotations.json"

# Load current JSON annotations
with open(json_path, "r") as f:
    annotations_json = json.load(f)

# Helper to convert XML to your JSON format
def parse_xml_to_json(xml_file):
    tree = ET.parse(xml_file)
    root = tree.getroot()

    filename = root.find("filename").text
    obj = root.find("object")
    label = obj.find("name").text

    bndbox = obj.find("bndbox")
    xmin = int(bndbox.find("xmin").text)
    ymin = int(bndbox.find("ymin").text)
    xmax = int(bndbox.find("xmax").text)
    ymax = int(bndbox.find("ymax").text)

    width = xmax - xmin
    height = ymax - ymin
    x_center = xmin + width / 2
    y_center = ymin + height / 2

    return {
        "image": filename,
        "annotations": [
            {
                "label": label,
                "coordinates": {
                    "x": x_center,
                    "y": y_center,
                    "width": width,
                    "height": height
                }
            }
        ]
    }

# Loop through all XML files
for file_name in os.listdir(xml_folder):
    if file_name.endswith(".xml"):
        full_path = os.path.join(xml_folder, file_name)
        new_annotation = parse_xml_to_json(full_path)
        annotations_json.append(new_annotation)

# Save updated annotations.json
with open(json_path, "w") as f:
    json.dump(annotations_json, f, indent=4)

print("Annotations added successfully.")