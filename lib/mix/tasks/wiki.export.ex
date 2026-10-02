defmodule Mix.Tasks.Wiki.Export do
  use Mix.Task
  @shortdoc "Export 15 starter wiki pages and up to 5 demo journals as MediaWiki XML"
  def run(_) do
    Mix.Task.run("app.start")

    guides = [
      {"Main Page",
       "Welcome to the open repair knowledge base. Repair over Replace. Start with [[Safety first]] and [[Getting started with repair]]. This is fictional POC seed content, not professionally reviewed repair guidance."},
      {"Safety first",
       "Stop if a repair involves mains electricity, gas, swollen batteries, vehicle brakes or steering, medical devices or lifts. Seek qualified help. Never bypass a safety device. Learners work only under supervision."},
      {"Before handing over a device",
       "Back up your data, remove removable storage, sign out of sensitive accounts and agree how access will be handled. Do not share passwords in public repair requests. Record the item's condition without publishing serial numbers."},
      {"Getting started with repair",
       "Describe the item and symptoms. Record what you tried without attempting dangerous work. Find a local technician or attend a repair event, watch and ask questions, then document the outcome."},
      {"Repair journals",
       "A journal records one repair: symptoms, attempts, diagnosis, parts, who bought them, agreed cost and outcome. Credit the requester. Credit the technician only with consent. Review private details before publishing under CC BY-SA 4.0."},
      {"Responsible e-waste disposal",
       "Keep electronics separate from household waste. Ask your local authority for an authorised collection point. Damaged batteries require specialist handling; do not puncture, heat or dismantle them. Remove personal data where safely possible."},
      {"Repair event organiser checklist",
       "Confirm venue permission and accessibility, competent supervision, power isolation, first aid and fire arrangements. Explain rules at arrival. Owners stay with items; all items and replaced parts go home. Record attendance and publish a summary."},
      {"Apprenticeship at events",
       "Choose an attending mentor and request a place. Wait for acceptance. Ask before using tools. Your mentor records supervised hours and attendance; these become part of your public learning record."},
      {"Documenting a fault",
       "Record brand/model if known, when the symptom started, and whether it is intermittent. Describe observations rather than guessing the cause. Avoid publishing personal data. Stop using an unsafe item."},
      {"Repair photos and consent",
       "Use only your own photos or appropriately licensed media. Exclude faces, addresses, passwords and serial numbers. Request photos are not automatically licensed for Commons. Obtain informed consent before any public upload."},
      {"Agreeing a repair price",
       "Ask about diagnosis fees, labour, parts and warranty before work. Agree changes directly and write them in the tracking log. The platform takes no commission and processes no payments. Never pay in advance for unseen work."},
      {"Parts and replaced components",
       "Record what was replaced, who sourced it and its cost. Check compatibility with the technician. Replaced parts belong to the owner unless agreed otherwise. Use authorised disposal for unsafe waste."},
      {"Bicycle repair intake",
       "Record the affected component and symptoms. Do not ride an unsafe bicycle. Brakes, steering and structural damage need competent assessment. This intake page is not a repair procedure."},
      {"Clothing repair intake",
       "Describe fabric, seam or fastening damage and the desired outcome. Bring matching material if available. Agree whether a visible patch is acceptable. Ask the repairer how to prevent recurrence."},
      {"Household electronics intake",
       "Record symptoms without opening a powered device. Stop using damaged cables or overheating equipment. Back up data when relevant. Ask a qualified technician to diagnose electrical hazards; do not use these notes as an electrical repair guide."}
    ]

    journals = Werepair.Repairs.list() |> Enum.filter(&(not is_nil(&1.outcome))) |> Enum.take(5)

    pages =
      guides ++
        Enum.map(journals, fn r ->
          {"Journal:Repair #{r.id}", Werepair.Wiki.journal(Werepair.Repairs.get!(r.id))}
        end)

    escape = fn text -> text |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string() end

    xml =
      Enum.map_join(pages, "\n", fn {title, text} ->
        "<page><title>#{escape.(title)}</title><ns>0</ns><revision><timestamp>#{DateTime.to_iso8601(DateTime.utc_now())}</timestamp><contributor><username>Werepair demo seed</username></contributor><comment>Fictional POC starter content, CC BY-SA 4.0</comment><model>wikitext</model><format>text/x-wiki</format><text xml:space=\"preserve\">#{escape.(text <> "\n\n[[Category:POC demo content]]")}</text></revision></page>"
      end)

    File.mkdir_p!("data")

    File.write!(
      "data/wiki-seed.xml",
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?><mediawiki xmlns=\"http://www.mediawiki.org/xml/export-0.11/\" version=\"0.11\" xml:lang=\"en\">#{xml}</mediawiki>"
    )

    Mix.shell().info(
      "Exported #{length(pages)} pages to data/wiki-seed.xml. No wiki deployment or remote writes performed."
    )
  end
end
