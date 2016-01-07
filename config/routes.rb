Localdoc::Engine.routes.draw do
  root to: "applicaiton#show"
  get "(*path)", to: "application#show", as: "show"
  put "*path", to: :"application#update"
end
