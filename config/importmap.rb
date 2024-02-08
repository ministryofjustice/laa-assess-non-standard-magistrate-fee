# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin 'application', preload: true
pin '@hotwired/turbo-rails', to: 'turbo.min.js', preload: true
pin '@hotwired/stimulus', to: 'stimulus.min.js', preload: true
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js', preload: true
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin "govuk-frontend", to: "https://ga.jspm.io/npm:govuk-frontend@5.0.0/dist/govuk/all.mjs"
pin "@ministryofjustice/frontend", to: "https://ga.jspm.io/npm:@ministryofjustice/frontend@2.1.0/moj/all.js"
pin "jquery", to: "https://ga.jspm.io/npm:jquery@3.7.1/dist/jquery.js"
