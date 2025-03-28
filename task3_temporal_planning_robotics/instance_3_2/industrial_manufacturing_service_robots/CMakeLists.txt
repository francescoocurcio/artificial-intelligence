cmake_minimum_required(VERSION 3.5)
project(industrial_manufacturing_service_robots)


find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(rclcpp_action REQUIRED)
find_package(plansys2_msgs REQUIRED)
find_package(plansys2_executor REQUIRED)

set(CMAKE_CXX_STANDARD 17)

set(dependencies
    rclcpp
    rclcpp_action
    plansys2_msgs
    plansys2_executor
)

add_executable(empty_box_in_location_action_node src/empty_box_in_location_action_node.cpp)
ament_target_dependencies(empty_box_in_location_action_node ${dependencies})

add_executable(empty_box_in_workstation_action_node src/empty_box_in_workstation_action_node.cpp)
ament_target_dependencies(empty_box_in_workstation_action_node ${dependencies})

add_executable(enter_workstation_action_node src/enter_workstation_action_node.cpp)
ament_target_dependencies(enter_workstation_action_node ${dependencies})

add_executable(exit_workstation_action_node src/exit_workstation_action_node.cpp)
ament_target_dependencies(exit_workstation_action_node ${dependencies})

add_executable(fill_box_in_location_action_node src/fill_box_in_location_action_node.cpp)
ament_target_dependencies(fill_box_in_location_action_node ${dependencies})

add_executable(fill_box_in_warehouse_action_node src/fill_box_in_warehouse_action_node.cpp)
ament_target_dependencies(fill_box_in_warehouse_action_node ${dependencies})

add_executable(fill_box_in_workstation_action_node src/fill_box_in_workstation_action_node.cpp)
ament_target_dependencies(fill_box_in_workstation_action_node ${dependencies})

add_executable(load_box_from_location_action_node src/load_box_from_location_action_node.cpp)
ament_target_dependencies(load_box_from_location_action_node ${dependencies})

add_executable(load_box_from_workstation_action_node src/load_box_from_workstation_action_node.cpp)
ament_target_dependencies(load_box_from_workstation_action_node ${dependencies})

add_executable(move_to_location_action_node src/move_to_location_action_node.cpp)
ament_target_dependencies(move_to_location_action_node ${dependencies})

add_executable(move_to_warehouse_action_node src/move_to_warehouse_action_node.cpp)
ament_target_dependencies(move_to_warehouse_action_node ${dependencies})

add_executable(put_down_box_in_location_action_node src/put_down_box_in_location_action_node.cpp)
ament_target_dependencies(put_down_box_in_location_action_node ${dependencies})

add_executable(put_down_box_in_workstation_action_node src/put_down_box_in_workstation_action_node.cpp)
ament_target_dependencies(put_down_box_in_workstation_action_node ${dependencies})


install(DIRECTORY launch pddl DESTINATION share/${PROJECT_NAME})

install(TARGETS
  empty_box_in_location_action_node
  empty_box_in_workstation_action_node
  enter_workstation_action_node
  exit_workstation_action_node
  fill_box_in_location_action_node
  fill_box_in_warehouse_action_node
  fill_box_in_workstation_action_node
  load_box_from_location_action_node
  load_box_from_workstation_action_node
  move_to_location_action_node
  move_to_warehouse_action_node
  put_down_box_in_location_action_node
  put_down_box_in_workstation_action_node
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION lib/${PROJECT_NAME}
)

if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  ament_lint_auto_find_test_dependencies()

  find_package(ament_cmake_gtest REQUIRED)
endif()

ament_export_dependencies(${dependencies})

ament_package()
