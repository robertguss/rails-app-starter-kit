class HomeController < ApplicationController
  def show
    render inertia: "home/show", props: {
      versions: {
        rails: Rails.version,
        ruby: RUBY_VERSION,
        inertia: InertiaRails::VERSION
      }
    }
  end
end
