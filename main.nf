nextflow.enable.dsl=1
inbox = params.inbox
staging = params.staging
logs = params.logs

files = file("$inbox/*")

process fileInfo {
    input:
    val f from files

    output:
    tuple val(name),env(MD5),val(size) into fileInfoOutput
    val f into fileMoveInput

    shell:
    size = f.size()
    name = f.getName()
    """
    MD5=\$(md5 -q $f)
    """
}

process fileMove {
    input:
    val f from fileMoveInput

    exec:
    f.moveTo(staging)
}

logInput = fileInfoOutput.toList()

process log {
    input:
    val f from logInput

    exec:
    Date date = new Date()
    String logfile = date.format("yyyy-mm-dd") + ".log"
    fh = file(logs + '/' + logfile)
    f.each {
        outputString = sprintf("%s\t%s\t%s\n",it)
        fh << outputString
    }
}


