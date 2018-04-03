#include "RealTimeSynchronizer.h"
#include "BlockInformation.h"
#include "Log.h"

#include <yarp/os/Time.h>

using namespace wbt;

const std::string RealTimeSynchronizer::ClassName = "RealTimeSynchronizer";

const unsigned PARAM_IDX_BIAS = Block::NumberOfParameters - 1;
const unsigned PARAM_IDX_PERIOD = PARAM_IDX_BIAS + 1;

unsigned RealTimeSynchronizer::numberOfParameters()
{
    return Block::numberOfParameters() + 1;
}

}

bool RealTimeSynchronizer::configureSizeAndPorts(BlockInformation* blockInfo)
{
    if (!Block::initialize(blockInfo)) {
        return false;
    }

    // INPUTS
    // ======
    //
    // No inputs
    //

    if (!blockInfo->setNumberOfInputPorts(0)) {
        wbtError << "Failed to set input port number to 0.";
        return false;
    }

    // OUTPUTS
    // =======
    //
    // No outputs
    //

    if (!blockInfo->setNumberOfOutputPorts(0)) {
        wbtError << "Failed to set output port number.";
        return false;
    }

    return true;
}

bool RealTimeSynchronizer::initialize(BlockInformation* blockInfo)
{
    if (!blockInfo->getScalarParameterAtIndex(PARAM_PERIOD, m_period)) {
        wbtError << "Failed to parse parameters.";
        return false;
    }

    if (m_period < 0) {
        wbtError << "Failed to get parameter 'period' after its parsing.";
        return false;
    }

    m_counter = 0;
    return true;
}

bool RealTimeSynchronizer::terminate(const BlockInformation* blockInfo)
{
    return true;
}

bool RealTimeSynchronizer::output(const BlockInformation* blockInfo)
{
    if (m_counter == 0) {
        m_initialTime = yarp::os::Time::now();
    }

    // read current time
    double currentTime = yarp::os::Time::now() - m_initialTime;
    double desiredTime = m_counter * m_period;

    double sleepPeriod = desiredTime - currentTime;

    // sleep for the remaining time
    if (sleepPeriod > 0) {
        yarp::os::Time::delay(sleepPeriod);
    }

    m_counter++;

    return true;
}
