FROM ghcr.io/cirruslabs/flutter:3.41.4

# 设置环境变量
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk
ENV PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$JAVA_HOME/bin

# 安装依赖
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    openjdk-17-jdk \
    cmake \
    ninja-build \
    clang \
    libgtk-3-dev \
    && rm -rf /var/lib/apt/lists/*

# 下载 Android SDK
RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O /tmp/android-tools.zip && \
    unzip -q /tmp/android-tools.zip -d /opt/android-sdk && \
    mkdir -p /opt/android-sdk/cmdline-tools && \
    mv /opt/android-sdk/cmdline-tools /opt/android-sdk/cmdline-tools-old && \
    mv /opt/android-sdk/cmdline-tools-old /opt/android-sdk/cmdline-tools/latest && \
    rm /tmp/android-tools.zip

# 接受许可并安装 Android 平台
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# 设置工作目录
WORKDIR /app

# 预缓存 Flutter 组件
RUN flutter precache && \
    flutter doctor -v

CMD ["/bin/bash"]
