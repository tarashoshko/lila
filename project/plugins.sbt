resolvers += Resolver.url(
  "lila-maven-sbt",
  url("https://raw.githubusercontent.com/lichess-org/lila-maven/master")
)(Resolver.ivyStylePatterns)
addSbtPlugin("com.typesafe.play" % "sbt-plugin"   % "2.8.18-lila_1.25") // scala2 branch
addSbtPlugin("org.scalameta"     % "sbt-scalafmt" % "2.5.2")
addSbtPlugin("ch.epfl.scala"     % "sbt-bloop"    % "1.6.0")
addSbtPlugin("com.github.sbt"    % "sbt-native-packager" % "1.9.12")
