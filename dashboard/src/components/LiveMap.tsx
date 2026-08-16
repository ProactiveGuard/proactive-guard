"use client";

import {
  MapContainer,
  TileLayer,
  Marker,
  Popup,
  Circle,
  Polyline
} from "react-leaflet";

import L from "leaflet";

delete (L.Icon.Default.prototype as any)._getIconUrl;

L.Icon.Default.mergeOptions({
  iconRetinaUrl:
    "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png",

  iconUrl:
    "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png",

  shadowUrl:
    "https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png"
});

export default function LiveMap() {
  const dangerLocation: [number, number] = [
    28.6139,
    77.2090
  ];

  const userPath: [number, number][] = [
    [28.6110, 77.2050],
    [28.6125, 77.2075],
    [28.6139, 77.2090]
  ];

  return (
    <div
      style={{
        height: "400px",
        width: "100%",
        borderRadius: "10px",
        overflow: "hidden"
      }}
    >
      <MapContainer
        center={dangerLocation}
        zoom={15}
        style={{
          height: "100%",
          width: "100%"
        }}
      >
        <TileLayer
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        />

        <Circle
          center={dangerLocation}
          pathOptions={{
            color: "red",
            fillColor: "red"
          }}
          radius={300}
        />

        <Marker position={dangerLocation}>
          <Popup>
            🚨 Incident INC-1001
          </Popup>
        </Marker>

        <Polyline
          positions={userPath}
          pathOptions={{
            color: "blue",
            weight: 4
          }}
        />
      </MapContainer>
    </div>
  );
}