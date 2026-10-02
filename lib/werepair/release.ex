defmodule Werepair.Release do
  @moduledoc "Explicit demo bootstrap for an OTP release; safe to rerun on the same volume."
  def seed_demo do
    Application.load(:werepair)

    unless Application.get_env(:werepair, :demo) && System.get_env("ALLOW_DEMO_SEED") == "true" do
      raise "Seeding a release requires DEMO=true and ALLOW_DEMO_SEED=true"
    end

    {:ok, _} = Application.ensure_all_started(:werepair)
    Code.eval_file(Application.app_dir(:werepair, "priv/repo/seeds.exs"))
  end
end
