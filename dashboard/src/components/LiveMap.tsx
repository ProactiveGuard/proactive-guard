"use client";

import { useEffect } from "react";
import {
  MapContainer,
  TileLayer,
  Marker,
  Popup,
  Circle,
  Polyline,
  useMap
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

function MapCameraman({ targetLat, targetLng }: { targetLat: number; targetLng: number }) {
  const map = useMap();

  useEffect(() => {
    map.flyTo([targetLat, targetLng], 15);
  }, [map, targetLat, targetLng]);

  return null;
}

interface MapProps {
  targetLat: number;
  targetLng: number;
  routeCoords?: [number, number][];
  safeZones?: {
    lat: number;
    lng: number;
    radius: number;
  }[];
}

export default function LiveMap({ targetLat, targetLng, routeCoords, safeZones }: MapProps) {
  const dangerLocation: [number, number] = [targetLat, targetLng];

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
        <MapCameraman targetLat={targetLat} targetLng={targetLng} />

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

        {routeCoords && routeCoords.length > 1 && (
          <Polyline
            positions={routeCoords}
            pathOptions={{
              color: "blue",
              weight: 4,
              dashArray: "10,10"
            }}
          />
        )}
      </MapContainer>
    </div>
  );
}