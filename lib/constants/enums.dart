enum FishType {
  seaFish('Sea Fish'),
  freshWaterFish('Fresh Water Fish');

  final String label;
  const FishType(this.label);
}

enum WestBengalState {
  kolkata('Kolkata'),
  howrah('Howrah'),
  hooghly('Hooghly'),
  northTwentyFourParganas('North 24 Parganas'),
  southTwentyFourParganas('South 24 Parganas'),
  nadia('Nadia'),
  murshidabad('Murshidabad'),
  malda('Malda'),
  jalpaiguri('Jalpaiguri'),
  darjeeling('Darjeeling'),
  coochBehar('Cooch Behar'),
  bankura('Bankura'),
  purulia('Purulia'),
  barddhaman('Barddhaman'),
  birbhum('Birbhum'),
  medinipur('Medinipur'),
  eastMedinipur('East Medinipur'),
  westMedinipur('West Medinipur'),
  dakshinDinajpur('Dakshin Dinajpur'),
  uttarDinajpur('Uttar Dinajpur'),
  alipurduar('Alipurduar'),
  kalimpong('Kalimpong'),
  jhargram('Jhargram');

  final String label;
  const WestBengalState(this.label);
}

enum TimeFilter {
  day('Daily'),
  month('Monthly'),
  year('Yearly');

  final String label;
  const TimeFilter(this.label);
}
