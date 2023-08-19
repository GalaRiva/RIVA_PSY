import '../user_data/user.dart';

class DataSourceService {
  static DataSource? _dataSource;

  static void setLocalDataSource() {
    _dataSource = DataSource.Local;
  }

  static void setRemoteDataSource() {
    _dataSource = DataSource.Remote;
  }

  static bool dataSourceIsRemote() {
    print(_dataSource);
    return _dataSource == DataSource.Remote;
  }

  static void getDataSourceType() {
    //if (CurrentUser.tariffIsStandard()) {
     // setLocalDataSource();
    //} else {
      setRemoteDataSource();
    //}
  }
}

enum DataSource {Local, Remote }
