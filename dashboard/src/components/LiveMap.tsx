"use client";

import { useEffect, useRef, useState } from "react";
import {
  MapContainer,
  TileLayer,
  Marker,
  Popup,
  Circle,
  Polyline,
  useMap,
  useMapEvents
} from "react-leaflet";
import MarkerClusterGroup from "react-leaflet-markercluster";

import L from "leaflet";
import "leaflet.markercluster/dist/MarkerCluster.css";
import "leaflet.markercluster/dist/MarkerCluster.Default.css";

delete (L.Icon.Default.prototype as any)._getIconUrl;

L.Icon.Default.mergeOptions({
  iconRetinaUrl:
    "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png",
  iconUrl:
    "https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png",
  shadowUrl:
    "https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png"
});

const severityColors: Record<string, string> = {
  CRITICAL: "red",
  "HIGH RISK": "orange",
  MONITOR: "yellow",
  SAFE: "green",
};

function MapCameraman({ lat, lng }: { lat: number, lng: number }) {
  const map = useMap();

  useEffect(() => {
    map.flyTo([lat, lng], 15, { animate: true, duration: 1.5 });
  }, [lat, lng, map]);

  return null;
}

function AutoPan({ incidents }: { incidents: Array<{ latitude: number; longitude: number }> }) {
  const map = useMap();
  useEffect(() => {
    if (incidents.length > 0) {
      const latest = incidents[0];
      map.flyTo([latest.latitude, latest.longitude], 15, { animate: true, duration: 1.5 });
    }
  }, [incidents, map]);
  return null;
}

function MapRef({ onReady }: { onReady: (map: L.Map) => void }) {
  const map = useMap();
  useEffect(() => {
    onReady(map);
  }, [map, onReady]);
  return null;
}

interface MapProps {
  targetLat: number;
  targetLng: number;
  incidents?: Array<{
    incident_id: string;
    severity: string;
    risk_score: number;
    latitude: number;
    longitude: number;
    summary: string;
  }>;
  routeCoords?: [number, number][];
  safeZones?: Array<{ lat: number; lng: number; radius: number }>;
  darkMode?: boolean;
  onExportMap?: () => void;
}

export default function LiveMap({
  targetLat,
  targetLng,
  incidents = [],
  routeCoords,
  safeZones = [],
  darkMode = false,
  onExportMap
}: MapProps) {
  const mapRef = useRef<L.Map | null>(null);
  const dangerLocation: [number, number] = [targetLat, targetLng];

  const handleMapReady = (map: L.Map) => {
    mapRef.current = map;
  };

  const exportMapImage = async () => {
    if (!mapRef.current) return;
    try {
      const { default: leafletImage } = await import("leaflet-image");
      const canvas = await leafletImage(mapRef.current);
      const link = document.createElement("a");
      link.download = `proactive-guard-map-${Date.now()}.png`;
      link.href = canvas.toDataURL();
      link.click();
    } catch (error) {
      console.error("Failed to export map:", error);
      alert("Failed to export map. Make sure leaflet-image is installed.");
    }
  };

  const tileUrl = darkMode
    ? "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
    : "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png";
  const attribution = darkMode ? "© CARTO" : "© OpenStreetMap";

  return (
    <div
      style={{
        height: "400px",
        width: "100%",
        borderRadius: "10px",
        overflow: "hidden",
        position: "relative"
      }}
    >
      <MapContainer
        center={dangerLocation}
        zoom={15}
        style={{ height: "100%", width: "100%" }}
      >
        <MapRef onReady={handleMapReady} />
        <MapCameraman lat={targetLat} lng={targetLng} />
        {incidents.length > 0 && <AutoPan incidents={incidents} />}

        <TileLayer url={tileUrl} attribution={attribution} />

        {safeZones.map((zone, i) => (
          <Circle
            key={i}
            center={[zone.lat, zone.lng]}
            pathOptions={{
              color: "green",
              fillColor: "green",
              fillOpacity: 0.15,
              weight: 2
            }}
            radius={zone.radius}
          />
        ))}

        <MarkerClusterGroup
          options={{
            maxClusterRadius: 50,
            spiderfyOnMaxZoom: true,
            showCoverageOnHover: false,
            zoomToBoundsOnClick: true
          }}
        >
          {incidents.map((incident) => (
            <Marker key={incident.incident_id} position={[incident.latitude, incident.longitude]}>
              <Popup>
                <div style={{ minWidth: 200 }}>
                  <h4 style={{ margin: "0 0 8px", color: severityColors[incident.severity] || "red" }}>
                    🚨 {incident.incident_id}
                  </h4>
                  <p style={{ margin: "4px 0" }}><strong>Severity:</strong> {incident.severity}</p>
                  <p style={{ margin: "4px 0" }}><strong>Risk Score:</strong> {incident.risk_score}/100</p>
                  <p style={{ margin: "4px 0", fontSize: "12px" }}>{incident.summary}</p>
                </div>
              </Popup>
            </Marker>
          ))}
        </MarkerClusterGroup>

        {routeCoords && routeCoords.length > 1 && (
          <Polyline
            positions={routeCoords}
            pathOptions={{
              color: darkMode ? "#60a5fa" : "blue",
              weight: 4,
              dashArray: "10,10",
              opacity: 0.8
            }}
          />
        )}

        <Circle
          center={dangerLocation}
          pathOptions={{
            color: "red",
            fillColor: "red",
            fillOpacity: 0.2,
            weight: 2
          }}
          radius={300}
        />

        <Marker position={dangerLocation}>
          <Popup>
            🚨 Latest Incident
          </Popup>
        </Marker>
      </MapContainer>

      <div style={{ position: "absolute", top: 10, right: 10, display: "flex", gap: 8, zIndex: 1000 }}>
        <button
          onClick={exportMapImage}
          className="bg-white/90 hover:bg-white text-black px-3 py-1.5 rounded text-sm font-medium shadow-lg transition-colors flex items-center gap-1.5"
          title="Export Map as Image"
        >
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
            <polyline points="7 10 12 15 17 10" />
            <line x1="12" y1="15" x2="12" y2="3" />
          </svg>
          Export
        </button>
        {onExportMap && (
          <button
            onClick={onExportMap}
            className="bg-white/90 hover:bg-white text-black px-3 py-1.5 rounded text-sm font-medium shadow-lg transition-colors"
          >
            Export (Parent)
          </button>
        )}
      </div>
    </div>
  );
}