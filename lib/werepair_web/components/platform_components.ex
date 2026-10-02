defmodule WerepairWeb.PlatformComponents do
  use WerepairWeb, :html
  attr :requests, :list, required: true

  def request_list(assigns) do
    ~H"""
    <div id="request-list" class="cards">
      <p :if={@requests == []}>
        No requests yet. <a href={~p"/requests/new"}>Post an item</a>
        or <a href={~p"/events"}>find an event</a>.
      </p>
      <article :for={r <- @requests} id={"request-#{r.id}"}>
        <h3><a href={~p"/requests/#{r.id}"}>{r.title}</a></h3>
        <p><span class="badge">{String.replace(r.status, "_", " ")}</span> {r.area} · {r.category}</p>
        <p>{r.description |> String.slice(0, 130)}</p>
      </article>
    </div>
    """
  end

  attr :latitude, :float, default: nil
  attr :longitude, :float, default: nil

  def map(assigns) do
    ~H"""
    <div :if={@latitude && @longitude} class="map">
      <iframe
        title="OpenStreetMap location"
        loading="lazy"
        referrerpolicy="no-referrer"
        src={"https://www.openstreetmap.org/export/embed.html?" <> URI.encode_query(%{bbox: "#{@longitude - 0.02},#{@latitude - 0.015},#{@longitude + 0.02},#{@latitude + 0.015}", layer: "mapnik", marker: "#{@latitude},#{@longitude}"})}
      ></iframe>
      <a
        href={"https://www.openstreetmap.org/?mlat=#{@latitude}&mlon=#{@longitude}#map=15/#{@latitude}/#{@longitude}"}
        target="_blank"
        rel="noopener noreferrer"
      >View location · © OpenStreetMap contributors</a>
    </div>
    """
  end

  attr :type, :string, required: true
  attr :target_id, :integer, required: true

  def report_link(assigns) do
    ~H"""
    <a class="small" href={~p"/reports/new?type=#{@type}&id=#{@target_id}"}>Report</a>
    """
  end

  attr :stats, :map, required: true

  def track_record(assigns) do
    ~H"""
    <p id="track-record">
      <strong>{if @stats.jobs > 0 or @stats.events != [],
        do: "L5 · Activity track record",
        else: "L1 · New community member"}</strong>
      · Phone unverified
    </p>
    <p>
      {@stats.jobs} completed repairs · {length(@stats.events)} event records · {@stats.hours} apprenticeship hours · {@stats.journals} linked journals
    </p>
    <p>
      Rating: {if @stats.rating,
        do: "#{@stats.rating} / 5 (#{length(@stats.reviews)} reviews)",
        else: "No published reviews yet"}
    </p>
    """
  end
end
