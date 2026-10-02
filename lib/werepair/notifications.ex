defmodule Werepair.Notifications do
  import Swoosh.Email
  require Logger

  def send(user, subject, path) do
    if Application.get_env(:werepair, :email_delivery, true),
      do: deliver(user, subject, path),
      else: :ok
  end

  defp deliver(user, subject, path) do
    new()
    |> to({user.name, user.email})
    |> from({"werepair.fyi", "hello@werepair.fyi"})
    |> subject(subject)
    |> text_body("#{subject}\n#{WerepairWeb.Endpoint.url()}#{path}")
    |> Werepair.Mailer.deliver()
    |> case do
      {:ok, _} ->
        :ok

      {:error, reason} ->
        Logger.warning("Email delivery failed: #{inspect(reason)}")
        :ok
    end
  end
end
