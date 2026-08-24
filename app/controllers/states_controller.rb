class StatesController < ApplicationController
  def empty
    render inertia: "states/empty"
  end

  def loading
    render inertia: "states/loading"
  end
end
