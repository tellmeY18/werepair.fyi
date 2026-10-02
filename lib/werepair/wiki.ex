defmodule Werepair.Wiki do
  def base_url,
    do:
      Application.get_env(:werepair, :wiki_url, "https://wiki.werepair.fyi")
      |> String.trim_trailing("/")

  def page_url(title), do: base_url() <> "/index.php?" <> URI.encode_query(%{title: title})

  def editor_url(request),
    do:
      base_url() <>
        "/index.php?" <>
        URI.encode_query(%{title: "Journal:Repair #{request.id}", action: "edit"})

  def journal(request) do
    logs =
      request.entries
      |> Enum.filter(&(&1.kind in ["log", "status"]))
      |> Enum.map_join("\n\n", fn entry ->
        "#{escape(entry.body)}\n\nParts: #{escape(entry.parts)}; bought by: #{escape(entry.purchased_by)}; price: #{entry.price || "not recorded"} INR."
      end)

    credit =
      if request.credit_consent && request.technician,
        do: "\nTechnician: #{escape(request.technician.name)} (credit consent given).",
        else: ""

    """
    = Repair journal: #{escape(request.title)} =
    Source: [#{WerepairWeb.Endpoint.url()}/requests/#{request.id} Original repair request]
    Author: #{escape(request.requester.name)}#{credit}
    Licence: CC BY-SA 4.0. Review this draft for personal information before publishing.
    == Problem ==
    #{escape(request.description)}
    == What I tried ==
    #{escape(request.tried)}
    == Tracking log ==
    #{logs}
    == Outcome ==
    #{request.outcome}: #{escape(request.outcome_note)}
    [[Category:Repair journals]]
    """
  end

  defp escape(nil), do: ""
  defp escape(text), do: "<nowiki>" <> String.replace(text, ["<", ">"], "") <> "</nowiki>"
end
