class FacultyOption {
  final int id;
  final String name;
  final String iconAsset;

  FacultyOption({
    required this.id,
    required this.name,
    required this.iconAsset,
  });
}

final List<FacultyOption> facultyOptions = [
  FacultyOption(
    id: 2,
    name: 'Agronomická fakulta',
    iconAsset: 'assets/images/af.png',
  ),
  FacultyOption(
    id: 4,
    name: 'Provozně ekonomická fakulta',
    iconAsset: 'assets/images/pef.png',
  ),
  FacultyOption(
    id: 3,
    name: 'Lesnická a dřevařská fakulta',
    iconAsset: 'assets/images/ldf.png',
  ),
  FacultyOption(
    id: 7,
    name: 'Institut celoživotního vzdělávání',
    iconAsset: 'assets/images/icv.png',
  ),
  FacultyOption(
    id: 6,
    name: 'Fakulta regionálního rozvoje...',
    iconAsset: 'assets/images/frrms.png',
  ),
  FacultyOption(
    id: 5,
    name: 'Zahradnická fakulta',
    iconAsset: 'assets/images/zf.png',
  ),
  FacultyOption(
    id: 1,
    name: 'Mendelova univerzita',
    iconAsset: 'assets/images/mendelu.png',
  ),
];

final List<FacultyOption> groupOptions = [
  FacultyOption(
    id: 1,
    name: 'Studenti',
    iconAsset: 'assets/images/student.png',
  ),
  FacultyOption(
    id: 2,
    name: 'Zaměstnanci',
    iconAsset: 'assets/images/employee.png',
  ),
  FacultyOption(
    id: 3,
    name: 'Absolventi',
    iconAsset: 'assets/images/graduate.png',
  ),
  FacultyOption(
    id: 4,
    name: 'Veřejnost',
    iconAsset: 'assets/images/student.png',
  ),
];
