# Buildr 1.4.6 build file for the Search Platform builds
# GLG 2012 - squince

# Version number for this release
# TODO: Need to investigate a way for Buildr to incorporate version with Git
#       either by using git tags or by modifying a file that is then commited
#       by Buildr so that it is properly incremented for each build.
VERSION_NUMBER = "1.0.0"
GROUP = "Search & Recommendations"
# TODO: Need to automate resolution of (c) date to be 2012 - currentyear()
COPYRIGHT = "(c) 2012 - Gerson Lehrman Group"

# Specify Maven 2.0 remote repositories here, like this:
repositories.remote << "http://repo1.maven.org/maven2" << "http://www.ibiblio.org/maven2" 

def solr_dependency(name)
  transitive(name + SOLR_VERSION).reject do |dep|
    dep.id == 'jmxtools' || dep.id == 'jmxri' || dep.group == 'javax.jms'
  end 
end

# DEPENDENCIES
JTDS = 'net.sourceforge.jtds:jtds:jar:1.2.4'
BSON4JACKSON = 'de.undercouch:bson4jackson:jar:1.3.0'
FLEXJSON = transitive('net.sf.flexjson:flexjson:jar:2.1')
MONGO = transitive('org.mongodb:mongo-java-driver:jar:2.8.0')
MYSQL = transitive('mysql:mysql-connector-java:jar:5.1.20')
XALAN = transitive('xalan:serializer:jar:2.7.1')
SOLR_VERSION = "4.0.0-BETA"
SOLR = struct(
  :solr		=> solr_dependency('org.apache.solr:solr:war:'),
  :dataimport	=> solr_dependency('org.apache.solr:solr-dataimporthandler:jar:'),
  :cell		=> solr_dependency('org.apache.solr:solr-cell:jar:'),
  :dataextra	=> solr_dependency('org.apache.solr:solr-dataimporthandler-extras:jar:'),
  :velocity     => solr_dependency('org.apache.solr:solr-velocity:jar:')
)

desc "Build Solr code for PI"

define "Pi-Solr" do

  project.version = VERSION_NUMBER
  project.group = GROUP
  manifest["Implementation-Vendor"] = COPYRIGHT

  # Project compiles .class files from .java source files that are (by default) assumed to be
  # in src/main/java... to specify a different source dir use the compile.from method
  # to specify a different destination/target directory for the compiled files use the
  # compile.into method.

  # Add classpath dependencies
  compile.with JTDS, MYSQL, FLEXJSON, BSON4JACKSON, MONGO, SOLR.solr, SOLR.dataimport, SOLR.cell, SOLR.dataextra, XALAN, SOLR.velocity

  # Package custom GLG jar
  package :jar, :file=>_('target/glgrecommend.jar')
  
  # Package Solr multicore engine
  package(:tgz, :file=>_('target/pi-solr.tgz')).tap do |path|
     path.include(_('pi-solr/solr-home')).exclude('.git','.DS_Store','README.txt','cores/*/data')
     path.include(_('pi-solr/jetty-home')).exclude('.git','.DS_Store','README.txt')
  end
 
  # Collect all Java library dependencies and solr.war for the TrendSetter Solr multicore engine Package
  package(:tgz, :file=>_('target/pi-solr.tgz')).path('solr-home/lib').include packages.select  { |pkg| pkg.type == :jar }
  compile.dependencies.select {|ref| package(:tgz, :file=>_('target/pi-solr.tgz')).path('solr-home').include(ref).exclude('*.jar')}
  compile.dependencies.select {|ref| package(:tgz, :file=>_('target/pi-solr.tgz')).path('solr-home/lib').include(ref).exclude('*.war')}

  packages.first.enhance do |task|
    task.enhance do
       filter.from('target').into('pi-solr/solr-home/lib').include('glgrecommend.jar').run
       compile.dependencies.map { |dep| FileUtils.cp dep.to_s , 'pi-solr/solr-home/lib' }
       FileUtils.mv 'pi-solr/solr-home/lib/' + 'solr-' + SOLR_VERSION + '.war' , 'pi-solr/solr-home/solr.war'
    end
  end

  task :dump_deps do
    #create lib folder if necessary
    #clear lib folder if exists
    compile.dependencies.map { |dep| FileUtils.cp dep.to_s , 'pi-solr/solr-home/lib/'}
  end

end
