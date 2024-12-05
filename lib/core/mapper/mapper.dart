abstract class UiEntityToDataModelMapper<Entity, Model> {
  Model mapperToDataModel(Entity entity);
  Entity mapperToEntity(Model model);
}