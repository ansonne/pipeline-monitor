import { CreatePipelineForm } from "@/components/create-pipeline-form";

export default function NewPipelinePage() {
  return (
    <div className="max-w-2xl">
      <h1 className="text-2xl font-semibold mb-6">New Pipeline</h1>
      <CreatePipelineForm />
    </div>
  );
}
