Localdoc::Engine.routes.draw do
  root to: "application#show"
  get "(*path)", to: "application#show", as: "show"
  put "*path", to: :"application#update", as: "update"
end
