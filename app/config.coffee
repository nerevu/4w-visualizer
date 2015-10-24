site_name = 'Kenya 4W'

config =
  whoField: 'Agency'
  whatField: 'Project Title'
  whereField: 'County'
  joinAttribute: 'COUNTY_NAM'
  nameAttribute: 'COUNTY_NAM'
  colorScheme: 'Blues'

  author:
    name: 'Reuben Cummings'
    url: 'https://reubano.github.io'
    email: 'reubano@gmail.com'

  site:
    title: site_name
    description: 'Who is Doing What Where in the Nepal Shelter Cluster'
    url: 'https://data.hdx.rwlabs.org/organization/global-shelter-cluster'
    id: 'com.3w.global-shelter-cluster'
    type: 'webapp'
    version: '0.1.0'
    keywords: """
      brunch, chaplin, nodejs, backbonejs, bower, html5, single page app
      """

    # Web pages
    home:
      id: '3w'
      page: '3w'
      href: '/3w'
      title: site_name

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
