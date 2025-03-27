#!/bin/bash
# 脚本放到代码根目录执行
#JAR_FILE=target/springboot-helloworld-0.0.1-SNAPSHOT.jar
# 应用配置
APP_NAME="springboot-helloworld"
VERSION="0.0.1"
JAR_FILE="target/${APP_NAME}-${VERSION}.jar"
PORT=8090
JVM_OPTS="-server -Xms256m -Xmx512m"
LOG_FILE="logs/${APP_NAME}.log"
PID_FILE="run/${APP_NAME}.pid"

# 创建必要目录
mkdir -p logs run

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查Maven
check_maven() {
  if ! command -v mvn &> /dev/null; then
    echo -e "${RED}错误: Maven未安装，请先安装Maven${NC}"
    exit 1
  fi
}

# 构建应用
build_app() {
  echo -e "${YELLOW}正在构建应用...${NC}"
  if ! mvn clean package; then
    echo -e "${RED}构建失败!${NC}"
    exit 1
  fi
}

# 启动应用
start() {
  if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p $PID > /dev/null; then
      echo -e "${YELLOW}应用已经在运行 (PID: $PID)${NC}"
      return
    fi
  fi

  if [ ! -f "$JAR_FILE" ]; then
    build_app
  fi

  echo -e "${YELLOW}正在启动应用...${NC}"
  nohup java $JVM_OPTS -jar "$JAR_FILE" >> "$LOG_FILE" 2>&1 &
  echo $! > "$PID_FILE"
  echo -e "${GREEN}应用已启动 (PID: $!)${NC}"
  sleep 3
  status
}

# 停止应用
stop() {
  if [ ! -f "$PID_FILE" ]; then
    echo -e "${YELLOW}应用未运行${NC}"
    return
  fi

  PID=$(cat "$PID_FILE")
  if ps -p $PID > /dev/null; then
    echo -e "${YELLOW}正在停止应用 (PID: $PID)...${NC}"
    kill $PID
    rm -f "$PID_FILE"
    echo -e "${GREEN}应用已停止${NC}"
  else
    echo -e "${YELLOW}应用未运行${NC}"
    rm -f "$PID_FILE"
  fi
}

# 重启应用
restart() {
  stop
  start
}

# 检查状态
status() {
  if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p $PID > /dev/null; then
      echo -e "${GREEN}应用正在运行 (PID: $PID)${NC}"
      echo -e "日志文件: $LOG_FILE"
      echo -e "访问地址: http://localhost:$PORT"
      return 0
    else
      rm -f "$PID_FILE"
    fi
  fi
  echo -e "${RED}应用未运行${NC}"
  return 1
}

# 查看日志
log() {
  if [ -f "$LOG_FILE" ]; then
    tail -f "$LOG_FILE"
  else
    echo -e "${YELLOW}日志文件不存在${NC}"
  fi
}

# 主逻辑
case "$1" in
  start)
    check_maven
    start
    ;;
  stop)
    stop
    ;;
  restart)
    check_maven
    restart
    ;;
  status)
    status
    ;;
  log)
    log
    ;;
  build)
    check_maven
    build_app
    ;;
  *)
    echo -e "${YELLOW}用法: $0 {start|stop|restart|status|log|build}${NC}"
    echo -e "  start   启动应用"
    echo -e "  stop    停止应用"
    echo -e "  restart 重启应用"
    echo -e "  status  查看状态"
    echo -e "  log     查看日志"
    echo -e "  build   构建应用"
    exit 1
    ;;
esac

exit 0
