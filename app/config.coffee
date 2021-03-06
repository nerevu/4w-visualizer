site_name = 'La Niña Consortium 4W'

config =
  whoField: 'Agency'
  whatField: 'Project Title'
  whereField: 'COUNTY'
  startField: 'start date'
  endField: 'End date'
  joinAttribute: 'COUNTY_NAM'
  nameAttribute: 'COUNTY_NAM'
  colorScheme: 'Oranges'
  dateFormat: 'DD/MM/YYYY'

  author:
    name: 'Nerevu Group, LLC'
    handle: 'nerevu'
    url: '//www.nerevu.com'
    email: 'reubano@gmail.com'

  site:
    title: site_name
    description: 'Emergency Interventions by La Niña Consortium'
    sub_description: 'Who is Doing What Where and When'
    url: '//showcase.nerevu.com/4w-visualizer/'
    data: '//github.com/nerevu/4w-visualizer/tree/master/app/data'
    source: '//github.com/nerevu/4w-visualizer'
    id: 'com.4w.red-cross-el-nino'
    type: 'webapp'
    version: '0.1.0'
    keywords: """
      brunch, chaplin, nodejs, backbonejs, bower, html5, single page app
      """

  google:
    analytics:
      id: $PROCESS_ENV_GOOGLE_ANALYTICS_TRACKING_ID ? null
      site_number: 3
    adwords_id: $PROCESS_ENV_GOOGLE_ADWORDS_ID ? null
    displayads_id: $PROCESS_ENV_GOOGLE_DISPLAYADS_ID ? null
    app_name: site_name
    app_id: ''
    plus_id: $PROCESS_ENV_GOOGLE_PLUS_ID ? null

  facebook:
    app_id: ''

module.exports = config
