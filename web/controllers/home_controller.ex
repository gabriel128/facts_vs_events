defmodule FactsVsEvents.HomeController do
  use FactsVsEvents.Web, :controller

  def index(conn, _params) do
    redirect(conn, to: fact_user_path(conn, :index))
  end
end
