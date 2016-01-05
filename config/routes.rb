Localdoc::Engine.routes.draw do
  get "(*path)", to: :show
  put "*path", to: :update
end
