import { Metadata } from "next";

interface PageProps {
  params: Promise<{ id: string }>;
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { id } = await params;
  return {
    title: `Incident ${id} - Proactive Guard`,
    description: `Details for incident ${id}`,
  };
}

export default async function IncidentDetailPage({ params }: PageProps) {
  const { id } = await params;

  return (
    <main className="min-h-screen bg-gray-900 text-white p-8">
      <h1 className="text-3xl font-bold text-red-500 mb-4">Incident Details</h1>
      <p className="text-gray-400">Incident ID: {id}</p>
      <p className="text-gray-400 mt-4">Detailed view coming soon...</p>
    </main>
  );
}